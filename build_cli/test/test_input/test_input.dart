// @dart=2.12

import 'package:build_cli_annotations/build_cli_annotations.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
  'Could not handle field `number`. `Duration` is not a supported type.',
)
@CliOptions()
class UnsupportedFieldType {
  Duration? number;
}

@ShouldThrow('Could not handle field `option`. '
    'The `defaultsTo` value – `a` is not in `allowedValues`.')
@CliOptions()
class DefaultNotInAllowed {
  @CliOption(defaultsTo: 'a', allowed: ['b'])
  String? option;
}

@ShouldThrow('Could not handle field `option`. '
    '`negatable` is only valid for flags – type `bool`.')
@CliOptions()
class NegatableOption {
  @CliOption(negatable: true)
  String? option;
}

@ShouldThrow('Could not handle field `options`. '
    '`negatable` is only valid for flags – type `bool`.')
@CliOptions()
class NegatableMultiOption {
  @CliOption(negatable: true)
  List<String>? options;
}

@ShouldThrow('Could not handle field `option`. '
    'The function provided for `convert` must be top-level. '
    'Static class methods (like `_staticConvertStringToDuration`) are not '
    'supported.')
@CliOptions()
class ConvertAsStatic {
  @CliOption(convert: _staticConvertStringToDuration)
  String? option;

  static Duration? _staticConvertStringToDuration(String source) => null;
}

@ShouldThrow('Could not handle field `option`. '
    'The convert function `_convertStringToDuration` return type '
    '`Duration` is not compatible with the field type `String`.')
@CliOptions()
class BadConvertReturn {
  @CliOption(convert: _convertStringToDuration)
  String? option;
}

Duration? _convertStringToDuration(String source) => null;

@ShouldThrow('Could not handle field `option`. '
    'The convert function `_convertStringToDuration` return type '
    '`Duration` is not compatible with the field type `List<Duration>`.')
@CliOptions()
class ConvertOnMulti {
  @CliOption(convert: _convertStringToDuration)
  List<Duration>? option;
}

@ShouldThrow(
  'Could not handle field `option`. '
  'The value for `defaultsTo` must be assignable to `bool`.',
)
@CliOptions()
class FlagWithStringDefault {
  @CliOption(defaultsTo: 'string')
  bool? option;
}

@ShouldThrow('Could not handle field `option`. '
    '`allowed` is not supported for flags.')
@CliOptions()
class FlagWithAllowed {
  @CliOption(allowed: [])
  bool? option;
}

@ShouldThrow('Could not handle field `option`. '
    '`allowedHelp` is not supported for flags.')
@CliOptions()
class FlagWithAllowedHelp {
  @CliOption(allowedHelp: {})
  bool? option;
}

@ShouldThrow('Could not handle field `option`. '
    '`valueHelp` is not supported for flags.')
@CliOptions()
class FlagWithValueHelp {
  @CliOption(valueHelp: 'string')
  bool? option;
}

@ShouldGenerate(r'''
Empty _$parseEmptyResult(ArgResults result) => Empty();

ArgParser _$populateEmptyParser(ArgParser parser) => parser;

final _$parserForEmpty = _$populateEmptyParser(ArgParser());

Empty parseEmpty(List<String> args) {
  final result = _$parserForEmpty.parse(args);
  return _$parseEmptyResult(result);
}
''')
@CliOptions()
class Empty {}

@ShouldGenerate(r'''
WithCommand _$parseWithCommandResult(ArgResults result) =>
    WithCommand()..command = result.command;

ArgParser _$populateWithCommandParser(ArgParser parser) => parser;

final _$parserForWithCommand = _$populateWithCommandParser(ArgParser());

WithCommand parseWithCommand(List<String> args) {
  final result = _$parserForWithCommand.parse(args);
  return _$parseWithCommandResult(result);
}
''')
@CliOptions()
class WithCommand {
  ArgResults? command;
}

@ShouldGenerate(r'''
SpecialNotAnnotated _$parseSpecialNotAnnotatedResult(ArgResults result) =>
    SpecialNotAnnotated()
      ..option = result['option'] as String?
      ..rest = result.rest
      ..command = result.command
      ..optionWasParsed = result.wasParsed('option');

ArgParser _$populateSpecialNotAnnotatedParser(ArgParser parser) =>
    parser..addOption('option');

final _$parserForSpecialNotAnnotated =
    _$populateSpecialNotAnnotatedParser(ArgParser());

SpecialNotAnnotated parseSpecialNotAnnotated(List<String> args) {
  final result = _$parserForSpecialNotAnnotated.parse(args);
  return _$parseSpecialNotAnnotatedResult(result);
}
''')
@CliOptions()
class SpecialNotAnnotated {
  String? option;
  bool? rest;
  ArgResults? command;
  bool? optionWasParsed;
}

@ShouldGenerate(r'''
AnnotatedCommandWithParser _$parseAnnotatedCommandWithParserResult(
        ArgResults result) =>
    AnnotatedCommandWithParser()
      ..command = _stringToArgsResults(result['command'] as String);

ArgParser _$populateAnnotatedCommandWithParserParser(ArgParser parser) =>
    parser..addOption('command');

final _$parserForAnnotatedCommandWithParser =
    _$populateAnnotatedCommandWithParserParser(ArgParser());

AnnotatedCommandWithParser parseAnnotatedCommandWithParser(List<String> args) {
  final result = _$parserForAnnotatedCommandWithParser.parse(args);
  return _$parseAnnotatedCommandWithParserResult(result);
}
''')
@CliOptions()
class AnnotatedCommandWithParser {
  @CliOption(convert: _stringToArgsResults)
  ArgResults? command;
}

ArgResults? _stringToArgsResults(String value) => null;

@ShouldThrow('Could not handle field `nothingWasParsed`. Could not find '
    'expected source field `nothing`.')
@CliOptions()
class LonelyWasParsed {
  bool? nothingWasParsed;
}

@ShouldThrow(
    'Could not handle field `command`. `ArgResults` is not a supported type.')
@CliOptions()
class AnnotatedCommandNoParser {
  @CliOption()
  ArgResults? command;
}

@ShouldThrow(
  'Generator cannot target `theAnswer`. `@CliOptions` can only be applied to a '
  'class.',
  todo: 'Remove the `@CliOptions` annotation from `theAnswer`.',
)
@CliOptions()
const theAnswer = 42;

@ShouldThrow(
    'Generator cannot target `annotatedMethod`.'
    ' `@CliOptions` can only be applied to a class.',
    todo: 'Remove the `@CliOptions` annotation from `annotatedMethod`.')
@CliOptions()
Object? annotatedMethod() => null;

@ShouldGenerate(r'''
T _$enumValueHelper<T>(Map<T, String> enumValues, String source) => enumValues
    .entries
    .singleWhere((e) => e.value == source,
        orElse: () =>
            throw ArgumentError('`$source` is not one of the supported values: '
                '${enumValues.values.join(', ')}'))
    .key;

T? _$nullableEnumValueHelperNullable<T>(
        Map<T, String> enumValues, String? source) =>
    source == null ? null : _$enumValueHelper(enumValues, source);

DefaultOverride _$parseDefaultOverrideResult(ArgResults result) =>
    DefaultOverride()
      ..shouldDoThing = result['should-do-thing'] as bool?
      ..otherSetting = result['other-setting'] as String?
      ..enumValue = _$nullableEnumValueHelperNullable(
          _$TestEnumEnumMap, result['enum-value'] as String);

const _$TestEnumEnumMap = <TestEnum, String>{
  TestEnum.alpha: 'alpha',
  TestEnum.beta: 'beta',
  TestEnum.$gama: r'$gama'
};

ArgParser _$populateDefaultOverrideParser(
  ArgParser parser, {
  bool? shouldDoThingDefaultOverride,
  String? otherSettingDefaultOverride,
  TestEnum? enumValueDefaultOverride,
}) =>
    parser
      ..addFlag('should-do-thing',
          defaultsTo: shouldDoThingDefaultOverride ?? null)
      ..addOption('other-setting',
          defaultsTo: otherSettingDefaultOverride ?? 'default value')
      ..addOption('enum-value',
          defaultsTo: _$TestEnumEnumMap[enumValueDefaultOverride],
          allowed: ['alpha', 'beta', r'$gama']);

final _$parserForDefaultOverride = _$populateDefaultOverrideParser(ArgParser());

DefaultOverride parseDefaultOverride(List<String> args) {
  final result = _$parserForDefaultOverride.parse(args);
  return _$parseDefaultOverrideResult(result);
}
''')
@CliOptions()
class DefaultOverride {
  @CliOption(provideDefaultToOverride: true)
  bool? shouldDoThing;

  @CliOption(provideDefaultToOverride: true, defaultsTo: 'default value')
  String? otherSetting;

  @CliOption(provideDefaultToOverride: true)
  TestEnum? enumValue;
}

enum TestEnum { alpha, beta, $gama }

@ShouldGenerate(r'''
PrivateCtor _$parsePrivateCtorResult(ArgResults result) =>
    PrivateCtor._(flag: result['flag'] as bool?);

ArgParser _$populatePrivateCtorParser(ArgParser parser) =>
    parser..addFlag('flag', defaultsTo: null);

final _$parserForPrivateCtor = _$populatePrivateCtorParser(ArgParser());

PrivateCtor parsePrivateCtor(List<String> args) {
  final result = _$parserForPrivateCtor.parse(args);
  return _$parsePrivateCtorResult(result);
}
''')
@CliOptions()
class PrivateCtor {
  final bool? flag;

  PrivateCtor._({this.flag});
}

@ShouldThrow('Could not pick a constructor to use.')
@CliOptions()
class TwoNonDefaultConstructors {
  final bool flag;

  TwoNonDefaultConstructors.values(this.flag);

  TwoNonDefaultConstructors.defaults() : flag = false;
}

@ShouldGenerate(r'''
T _$enumValueHelper<T>(Map<T, String> enumValues, String source) => enumValues
    .entries
    .singleWhere((e) => e.value == source,
        orElse: () =>
            throw ArgumentError('`$source` is not one of the supported values: '
                '${enumValues.values.join(', ')}'))
    .key;

T _$badNumberFormat<T extends num>(
        String source, String type, String argName) =>
    throw FormatException(
        'Cannot parse "$source" into `$type` for option "$argName".');

NonNullableTypes _$parseNonNullableTypesResult(ArgResults result) =>
    NonNullableTypes(
        name: result['name'] as String,
        enumValue: _$enumValueHelper(
            _$TestEnumEnumMap, result['enum-value'] as String),
        number: int.tryParse(result['number'] as String) ??
            _$badNumberFormat(result['number'] as String, 'int', 'number'));

const _$TestEnumEnumMap = <TestEnum, String>{
  TestEnum.alpha: 'alpha',
  TestEnum.beta: 'beta',
  TestEnum.$gama: r'$gama'
};

ArgParser _$populateNonNullableTypesParser(ArgParser parser) => parser
  ..addOption('name')
  ..addOption('enum-value', allowed: ['alpha', 'beta', r'$gama'])
  ..addOption('number');

final _$parserForNonNullableTypes =
    _$populateNonNullableTypesParser(ArgParser());

NonNullableTypes parseNonNullableTypes(List<String> args) {
  final result = _$parserForNonNullableTypes.parse(args);
  return _$parseNonNullableTypesResult(result);
}
''')
@CliOptions()
class NonNullableTypes {
  final String name;
  final TestEnum enumValue;
  final int number;

  NonNullableTypes({
    required this.name,
    required this.enumValue,
    required this.number,
  });
}
