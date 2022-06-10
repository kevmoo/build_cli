import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart' show log, BuildStep;
import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'arg_info.dart';
import 'enum_helpers.dart';
import 'to_share.dart';
import 'util.dart';

/// A `package:source_gen` `Generator` which generates CLI parsing code
/// for classes annotated with [CliOptions].
///
/// Developers shouldn't need to access this class directly unless they are
/// configuring a `package:source_gen` `PartBuilder` in code.
class CliGenerator extends GeneratorForAnnotation<CliOptions> {
  const CliGenerator();

  @override
  Stream<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async* {
    await validateSdkConstraint(buildStep);

    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`. '
        '`@CliOptions` can only be applied to a class.',
        todo: 'Remove the `@CliOptions` annotation from `$friendlyName`.',
        element: element,
      );
    }

    // Get all of the fields that need to be assigned
    // TODO: We only care about constructor things + writable fields, right?
    final fieldsList = createSortedFieldSet(element);

    // Explicitly using `LinkedHashMap` – we want these ordered.
    final fields = LinkedHashMap<String, FieldElement>.fromIterable(
      fieldsList,
      key: (f) => (f as FieldElement).name,
    );

    // Get the constructor to use for the factory

    final populateParserName = '_\$populate${element.name}Parser';
    final parserFieldName = '_\$parserFor${element.name}';
    final resultParserName = '_\$parse${element.name}Result';

    if (fieldsList.any((fe) => fe.type.isEnum)) {
      yield enumValueHelper;

      if (fieldsList.any(
        (fe) =>
            fe.type.isEnum &&
            fe.type.nullabilitySuffix != NullabilitySuffix.none,
      )) {
        yield nullableEnumValueHelper;
      }
    }

    if (fieldsList.any((fe) => numChecker.isAssignableFromType(fe.type))) {
      yield r'''
T _$badNumberFormat<T extends num>(
  String source,
  String type,
  String argName,
) =>
  throw FormatException(
    'Cannot parse "$source" into `$type` for option "$argName".',
  ); 
''';
    }

    var buffer = StringBuffer()
      ..write(
        '''
${element.name} $resultParserName(ArgResults result) =>''',
      );

    String deserializeForField(
      String fieldName, {
      ParameterElement? ctorParam,
    }) =>
        _deserializeForField(fields[fieldName]!, ctorParam, fields);

    final usedFields = writeConstructorInvocation(
      buffer,
      element,
      fields.keys,
      fields.values.where((fe) => !fe.isFinal).map((fe) => fe.name),
      {},
      deserializeForField,
    );

    final unusedFields = fields.keys.toSet()..removeAll(usedFields);

    if (unusedFields.isNotEmpty) {
      final fieldsString = unusedFields.map((f) => '`$f`').join(', ');
      log.warning('Skipping unassignable fields on `$element`: $fieldsString');

      unusedFields.forEach(fields.remove);
    }
    yield buffer.toString();

    final provideOverrides =
        fields.map((k, v) => MapEntry(k, ArgInfo.fromField(v)))
          ..removeWhere(
            (k, v) => !(v.optionData?.provideDefaultToOverride ?? false),
          );

    final fyis = <String>[];

    /// If an override has a converter, then we don't support passing the
    /// override in via the source type. You have to pass it in as a [String].
    String typeForOverride(String fieldName, ArgInfo info) {
      assert(info.optionData!.provideDefaultToOverride);
      String typeInfo;
      if (converterDataFromOptions(info.optionData!) == null) {
        typeInfo = info.dartType.getDisplayString(withNullability: false);
      } else {
        fyis.add(
          'The value for [${_overrideParamName(fieldName)}] must be a '
          '[String] that is convertible to '
          '[${info.dartType.getDisplayString(withNullability: false)}].',
        );
        typeInfo = 'String';
      }

      typeInfo = '$typeInfo?';

      return '$typeInfo ${_overrideParamName(fieldName)},';
    }

    var overrideArgs = '';
    if (provideOverrides.isNotEmpty) {
      overrideArgs = provideOverrides.entries
          .map((e) => typeForOverride(e.key, e.value))
          .join('\n');
      overrideArgs = ',{$overrideArgs}';
    }

    buffer = StringBuffer()
      ..writeAll(fyis.map((e) => '/// $e\n'))
      ..write(
        'ArgParser $populateParserName(ArgParser parser$overrideArgs) => '
        'parser',
      );
    for (var f in fields.values) {
      if (f.type.isEnum) {
        yield enumValueMapFromType(f.type)!;
      }

      _parserOptionFor(buffer, f);
    }
    buffer.write(';');
    yield buffer.toString();

    yield 'final $parserFieldName = $populateParserName(ArgParser());';

    yield '''
${element.name} parse${element.name}(List<String> args) {
  final result = $parserFieldName.parse(args);
  return $resultParserName(result);
}
''';

    final createCommand = annotation.read('createCommand').boolValue;
    if (createCommand) {
      yield '''
abstract class _\$${element.name}Command<T> extends Command<T> {
  _\$${element.name}Command() {
    $populateParserName(argParser);
  }

  late final _options => $resultParserName(argResults!);
}
      ''';
    }
  }
}

String _overrideParamName(String fieldName) => '${fieldName}DefaultOverride';

const _numCheckers = <TypeChecker, String>{
  numChecker: 'num',
  TypeChecker.fromRuntime(int): 'int',
  TypeChecker.fromRuntime(double): 'double'
};

String _deserializeForField(
  FieldElement field,
  ParameterElement? ctorParam,
  Map<String, FieldElement> allFields,
) {
  final info = ArgInfo.fromField(field);

  if (info.argType == ArgType.rest) {
    return 'result.rest';
  }

  if (info.argType == ArgType.wasParsed) {
    final name = field.name;
    assert(name.endsWith(wasParsedSuffix));
    final targetFieldName =
        name.substring(0, name.length - wasParsedSuffix.length);
    final targetField = allFields[targetFieldName];
    if (targetField == null) {
      throwUnsupported(
        field,
        'Could not find expected source field `$targetFieldName`.',
      );
    }
    return 'result.wasParsed(${_getArgNameStringLiteral(targetField)})';
  }

  if (info.argType == ArgType.command) {
    return 'result.command';
  }

  final targetType = ctorParam?.type ?? field.type;
  final argName = _getArgNameStringLiteral(field);

  final argAccess = 'result[$argName]';

  final convertName = converterDataFromOptions(info.optionData!);
  if (convertName != null) {
    //info.optionData!.
    assert(info.argType == ArgType.option);
    final nullableBit = convertName.nullable ? '?' : '';
    return '${convertName.name}($argAccess as String$nullableBit)';
  }

  if (stringChecker.isExactlyType(targetType) ||
      boolChecker.isExactlyType(targetType)) {
    final suffix =
        targetType.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
    return '$argAccess as ${targetType.element!.name}$suffix';
  }

  if (targetType.isEnum) {
    final helperName = targetType.isNullableType
        ? nullableEnumValueHelperFunctionName
        : enumValueHelperFunctionName;

    final nullableBit = targetType.isNullableType ? '?' : '';

    return '$helperName('
        '${enumConstMapName(targetType)}, $argAccess as String$nullableBit,)';
  }

  if (info.argType == ArgType.multiOption) {
    assert(isMulti(targetType));
    // if the target type is dynamic, Object, or String – just send it in as-is

    final args = targetType.typeArgumentsOf(listChecker)!;

    assert(args.length == 1);

    if (objectChecker.isExactlyType(args.single)) {
      return '$argAccess as List<Object>';
    }

    if (_dynamicChecker.isExactlyType(args.single) || args.single.isDynamic) {
      return '$argAccess as List';
    }

    if (stringChecker.isExactlyType(args.single)) {
      return '$argAccess as List<String>';
    }

    throwUnsupported(
      field,
      'Lists of type `${args.single}` are not supported.',
    );
  }

  for (var checker in _numCheckers.entries) {
    if (checker.key.isExactlyType(targetType)) {
      return '${checker.value}.tryParse($argAccess as String) ?? '
          "_\$badNumberFormat($argAccess as String, '${checker.value}', "
          "'${_getArgName(field)}',)";
    }
  }

  throwUnsupported(field, 'The type `$targetType` is not supported.');
}

String _getArgName(FieldElement element) =>
    ArgInfo.fromField(element).optionData?.name ?? element.name.kebab;

String _getArgNameStringLiteral(FieldElement element) =>
    escapeDartString(_getArgName(element));

void _parserOptionFor(StringBuffer buffer, FieldElement element) {
  final info = ArgInfo.fromField(element);

  switch (info.argType) {
    case ArgType.flag:
      buffer.write('..addFlag');
      break;
    case ArgType.option:
      buffer.write('..addOption');
      break;
    case ArgType.multiOption:
      buffer.write('..addMultiOption');
      break;
    default:
      if (specialTypes.keys.contains(info.argType)) {
        return;
      }
      throwBugFound(element);
  }
  buffer.write('(${_getArgNameStringLiteral(element)}');

  final options = info.optionData!;

  if (options.abbr != null) {
    buffer.write(', abbr: ${escapeDartString(options.abbr!)}');
  }

  if (options.help != null) {
    buffer.write(', help: ${escapeDartString(options.help!)}');
  }

  if (options.valueHelp != null) {
    buffer.write(', valueHelp: ${escapeDartString(options.valueHelp!)}');
  }

  final defaultsToValues = <String>[];

  if (options.provideDefaultToOverride) {
    if (info.dartType.isEnum) {
      defaultsToValues.add(
        '${enumConstMapName(element.type)}'
        '[${_overrideParamName(element.name)}]',
      );
    } else {
      defaultsToValues.add(_overrideParamName(element.name));
    }
  }

  if (info.argType == ArgType.flag &&
      element.type.nullabilitySuffix == NullabilitySuffix.question) {
    // If it's a flag (boolean) and the option is nullable, use the default
    // value – even if it's null.
    defaultsToValues.add((options.defaultsTo as bool?).toString());
  } else if (options.defaultsTo != null) {
    final defaultValueLiteral = (info.argType == ArgType.flag)
        ? (options.defaultsTo as bool).toString()
        : escapeDartString(options.defaultsTo.toString());

    if (defaultValueLiteral != 'false') {
      // Don't populate `defaultValue` if it's redundant (false)
      defaultsToValues.add(defaultValueLiteral);
    }
  }

  if (defaultsToValues.isNotEmpty) {
    assert(defaultsToValues.length <= 2);
    buffer.write(', defaultsTo: ${defaultsToValues.join(' ?? ')}');
  }

  if (options.allowed != null) {
    final allowedItems =
        options.allowed!.map((e) => escapeDartString(e.toString())).join(', ');
    buffer.write(', allowed: [$allowedItems]');
  }

  if (options.allowedHelp != null) {
    // TODO: throw/warn if `allowed` is null or doesn't match these?
    final allowedHelpItems = options.allowedHelp!.entries.map((e) {
      final escapedKey = escapeDartString(e.key.toString());
      final escapedValue = escapeDartString(e.value);
      return '$escapedKey: $escapedValue';
    }).join(',');
    buffer.write(', allowedHelp: <String, String>{$allowedHelpItems}');
  }

  if (options.negatable == false) {
    buffer.write(', negatable: ${options.negatable}');
  }

  if (options.hide != null) {
    buffer.write(', hide: ${options.hide}');
  }

  buffer.writeln(',)');
}

const _dynamicChecker = TypeChecker.fromRuntime(Object);
