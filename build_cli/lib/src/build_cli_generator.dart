import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart' show log;
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
      Element element, ConstantReader annotation, _) async {
    if (element is! ClassElement) {
      var friendlyName = friendlyNameForElement(element);
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`. '
          '`@CliOptions` can only be applied to a class.',
          todo: 'Remove the `@CliOptions` annotation from `$friendlyName`.');
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

    buffer.write('return ');

    String deserializeForField(String fieldName, {ParameterElement ctorParam}) {
      var field = fields[fieldName];
      try {
        return _deserializeForField(field, ctorParam, fields);
      } on UnsupportedError catch (e) {
        throw new InvalidGenerationSourceError(
            'Could handle field `${friendlyNameForElement(field)}` - '
            '${e.message}');
      }
    }

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

  var targetType = ctorParam?.type ?? field.type;
  var argName = _getArgNameStringLiteral(field);

  var argAccess = 'result[$argName]';

  if (stringChecker.isExactlyType(targetType) ||
      boolChecker.isExactlyType(targetType)) {
    return '$argAccess as ${targetType.name}';
  }

  if (isEnum(targetType)) {
    return "enumValueHelper('$targetType', $targetType.values, $argAccess as String)";
  }

  if (isMulti(targetType)) {
    return '$argAccess as List<String>';
  }

  String numOrElseLambda(String type) =>
      '''(source) => throw new FormatException('Cannot parse "\$source" into `$type` for option "${_getArgName(field)}".')''';

  if (const TypeChecker.fromRuntime(int).isExactlyType(targetType)) {
    return 'int.parse($argAccess as String, onError: ${numOrElseLambda('int')})';
  }

  if (const TypeChecker.fromRuntime(double).isExactlyType(targetType)) {
    return 'double.parse($argAccess as String, ${numOrElseLambda('double')})';
  }

  if (const TypeChecker.fromRuntime(num).isExactlyType(targetType)) {
    return 'num.parse($argAccess as String, ${numOrElseLambda('num')})';
  }

  throw new UnsupportedError('The type `$targetType` is not supported.');
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
    case ArgType.rest:
    case ArgType.wasParsed:
      return;
  }
  buffer.write('(${_getArgNameStringLiteral(element)}');

  var options = info.optionData;

  if (options.abbr != null) {
    buffer.write(', abbr: ${escapeDartString(options.abbr)}');
  }

  if (options.help != null) {
    buffer.write(', help: ${escapeDartString(options.help)}');
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
