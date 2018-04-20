import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart' show log, BuildStep;
import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'arg_info.dart';
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
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    await validateSdkConstraint(buildStep);

    if (element is! ClassElement) {
      var friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`. '
          '`@CliOptions` can only be applied to a class.',
          todo: 'Remove the `@CliOptions` annotation from `$friendlyName`.',
          element: element);
    }

    var classElement = element as ClassElement;

    // Get all of the fields that need to be assigned
    // TODO: We only care about constructor things + writable fields, right?
    var fieldsList = createSortedFieldSet(classElement);

    // Explicitly using `LinkedHashMap` – we want these ordered.
    var fields = new LinkedHashMap<String, FieldElement>.fromIterable(
        fieldsList,
        key: (f) => (f as FieldElement).name);

    // Get the constructor to use for the factory

    var buffer = new StringBuffer();

    var populateParserName = '_\$populate${classElement.name}Parser';
    var parserFieldName = '_\$parserFor${classElement.name}';
    var resultParserName = '_\$parse${classElement.name}Result';

    buffer.writeln('''

${classElement.name} $resultParserName(ArgResults result) {

''');

    if (fieldsList.any((fe) => isEnum(fe.type))) {
      buffer.writeln(_enumValueHelper);
    }

    if (fieldsList.any((fe) => numChecker.isAssignableFromType(fe.type))) {
      buffer.writeln(r'''

T badNumberFormat<T extends num>(String source, String type, String argName) =>
  throw new FormatException('Cannot parse "$source" into `$type` for option "$argName".'); 
''');
    }

    buffer.write('return ');

    String deserializeForField(String fieldName,
            {ParameterElement ctorParam}) =>
        _deserializeForField(fields[fieldName], ctorParam, fields);

    var usedFields = writeConstructorInvocation(
        buffer,
        classElement,
        fields.keys,
        fields.values.where((fe) => !fe.isFinal).map((fe) => fe.name),
        {},
        deserializeForField);

    var unusedFields = fields.keys.toSet()..removeAll(usedFields);

    if (unusedFields.isNotEmpty) {
      var fieldsString = unusedFields.map((f) => '`$f`').join(', ');
      log.warning(
          'Skipping unassignable fields on `$classElement`: $fieldsString');

      for (var unusedField in unusedFields) {
        fields.remove(unusedField);
      }
    }

    buffer.writeln('''}

ArgParser $populateParserName(ArgParser parser) => parser''');

    for (var f in fields.values) {
      _parserOptionFor(buffer, f);
    }

    buffer.writeln(''';

final $parserFieldName = $populateParserName(new ArgParser());

${classElement.name} parse${classElement.name}(List<String> args) {
  var result = $parserFieldName.parse(args);
  return $resultParserName(result);
}
''');

    return buffer.toString();
  }
}

const _enumValueHelper = r'''
T enumValueHelper<T>(String enumName, List<T> values, String enumValue) =>
    enumValue == null
        ? null
        : values.singleWhere((e) => e.toString() == '$enumName.$enumValue',
            orElse: () => throw new StateError(
                'Could not find the value `$enumValue` in enum `$enumName`.'));
''';

final _numCheckers = <TypeChecker, String>{
  numChecker: 'num',
  const TypeChecker.fromRuntime(int): 'int',
  const TypeChecker.fromRuntime(double): 'double'
};

String _deserializeForField(FieldElement field, ParameterElement ctorParam,
    Map<String, FieldElement> allFields) {
  var info = ArgInfo.fromField(field);

  if (info.argType == ArgType.rest) {
    return 'result.rest';
  }

  if (info.argType == ArgType.wasParsed) {
    var name = field.name;
    assert(name.endsWith(wasParsedSuffix));
    var targetFieldName =
        name.substring(0, name.length - wasParsedSuffix.length);
    var targetField = allFields[targetFieldName];
    return 'result.wasParsed(${_getArgNameStringLiteral(targetField)})';
  }

  if (info.argType == ArgType.command) {
    return 'result.command';
  }

  var targetType = ctorParam?.type ?? field.type;
  var argName = _getArgNameStringLiteral(field);

  var argAccess = 'result[$argName]';

  var convertName = getConvertName(info.optionData);
  if (convertName != null) {
    assert(info.argType == ArgType.option);
    return '$convertName($argAccess as String)';
  }

  if (stringChecker.isExactlyType(targetType) ||
      boolChecker.isExactlyType(targetType)) {
    return '$argAccess as ${targetType.name}';
  }

  if (isEnum(targetType)) {
    return "enumValueHelper('$targetType', $targetType.values, $argAccess as String)";
  }

  if (info.argType == ArgType.multiOption) {
    assert(isMulti(targetType));
    // if the target type is dynamic, Object, or String – just send it in as-is

    var args = typeArgumentsOf(targetType, listChecker);

    assert(args.length == 1);

    if (_dynamicChecker.isExactlyType(args.single) || args.single.isDynamic) {
      return '$argAccess as List';
    }

    if (stringChecker.isExactlyType(args.single)) {
      return '$argAccess as List<String>';
    }

    throwUnsupported(
        field, 'Lists of type `${args.single}` are not supported.');
  }

  for (var checker in _numCheckers.entries) {
    if (checker.key.isExactlyType(targetType)) {
      return '${checker.value}.tryParse($argAccess as String) ?? '
          "badNumberFormat($argAccess as String, '${checker.value}', '${_getArgName(field)}')";
    }
  }

  throwUnsupported(field, 'The type `$targetType` is not supported.');
}

String _getArgName(FieldElement element) =>
    ArgInfo.fromField(element).optionData?.name ?? kebab(element.name);

String _getArgNameStringLiteral(FieldElement element) =>
    escapeDartString(_getArgName(element));

void _parserOptionFor(StringBuffer buffer, FieldElement element) {
  var info = ArgInfo.fromField(element);

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

  var options = info.optionData;

  if (options.abbr != null) {
    buffer.write(', abbr: ${escapeDartString(options.abbr)}');
  }

  if (options.help != null) {
    buffer.write(', help: ${escapeDartString(options.help)}');
  }

  if (options.valueHelp != null) {
    buffer.write(', valueHelp: ${escapeDartString(options.valueHelp)}');
  }

  if (options.defaultsTo != null) {
    var defaultValueLiteral = (info.argType == ArgType.flag)
        ? (options.defaultsTo as bool).toString()
        : escapeDartString(options.defaultsTo.toString());

    buffer.write(', defaultsTo: $defaultValueLiteral');
  }

  if (options.allowed != null) {
    var allowedItems = options.allowed.map((e) => "'$e'").join(', ');
    buffer.write(', allowed: [$allowedItems]');
  }

  if (options.allowedHelp != null) {
    // TODO: throw/warn if there if `allowed` is null?
    var allowedHelpItems = options.allowedHelp.entries.map((e) {
      var escapedKey = escapeDartString(e.key.toString());
      var escapedValue = escapeDartString(e.value);
      return '$escapedKey: $escapedValue';
    }).join(',');
    buffer.write(', allowedHelp: <String, String>{$allowedHelpItems}');
  }

  if (options.negatable != null) {
    buffer.write(', negatable: ${options.negatable}');
  }

  if (options.hide != null) {
    buffer.write(', hide: ${options.hide}');
  }

  buffer.writeln(')');
}

final _dynamicChecker = const TypeChecker.fromRuntime(Object);
