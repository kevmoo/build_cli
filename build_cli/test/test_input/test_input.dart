import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow('At least one constructor argument has an invalid type: `number`.',
    todo: 'Check names and imports.')
@CliOptions()
class UnknownCtorParamType {
  int number;

  // ignore: undefined_class, field_initializer_not_assignable, prefer_initializing_formals
  UnknownCtorParamType(Bob number) : number = number;
}

@ShouldThrow('Could not handle field `number`. It has an undefined type.',
    todo: 'Check names and imports.')
@CliOptions()
class UnknownFieldType {
  // ignore: undefined_class
  Bob number;
}

@ShouldThrow(
  'Could not handle field `number`. `Duration` is not a supported type.',
)
@CliOptions()
class UnsupportedFieldType {
  Duration number;
}

@ShouldThrow('Could not handle field `option`. '
    'The `defaultsTo` value – `a` is not in `allowedValues`.')
@CliOptions()
class DefaultNotInAllowed {
  @CliOption(defaultsTo: 'a', allowed: ['b'])
  String option;
}

@ShouldThrow('Could not handle field `option`. '
    '`negatable` is only valid for flags – type `bool`.')
@CliOptions()
class NegatableOption {
  @CliOption(negatable: true)
  String option;
}

@ShouldThrow('Could not handle field `options`. '
    '`negatable` is only valid for flags – type `bool`.')
@CliOptions()
class NegatableMultiOption {
  @CliOption(negatable: true)
  List<String> options;
}

@ShouldThrow('Could not handle field `option`. '
    'The function provided for `convert` must be top-level. '
    'Static class methods (like `_staticConvertStringToDuration`) are not supported.')
@CliOptions()
class ConvertAsStatic {
  @CliOption(convert: _staticConvertStringToDuration)
  String option;

  static Duration _staticConvertStringToDuration(String source) => null;
}

@ShouldThrow('Could not handle field `option`. '
    'The convert function `_convertStringToDuration` return type '
    '`Duration` is not compatible with the field type `String`.')
@CliOptions()
class BadConvertReturn {
  @CliOption(convert: _convertStringToDuration)
  String option;
}

Duration _convertStringToDuration(String source) => null;

@ShouldThrow('Could not handle field `option`. '
    'The convert function `_convertIntToString` must have one '
    'positional paramater of type `String`.')
@CliOptions()
class BadConvertParam {
  // ignore: argument_type_not_assignable
  @CliOption(convert: _convertIntToString)
  String option;
}

String _convertIntToString(int source) => null;

@ShouldThrow('Could not handle field `option`. '
    'The convert function `_convertStringToDuration` return type '
    '`Duration` is not compatible with the field type `List<Duration>`.')
@CliOptions()
class ConvertOnMulti {
  @CliOption(convert: _convertStringToDuration)
  List<Duration> option;
}

@ShouldThrow(
  'Could not handle field `option`. '
      'The value for `defaultsTo` must be assignable to `bool`.',
)
@CliOptions()
class FlagWithStringDefault {
  @CliOption(defaultsTo: 'string')
  bool option;
}

@ShouldThrow('Could not handle field `option`. '
    '`allowed` is not supported for flags.')
@CliOptions()
class FlagWithAllowed {
  @CliOption(allowed: [])
  bool option;
}

@ShouldThrow('Could not handle field `option`. '
    '`allowedHelp` is not supported for flags.')
@CliOptions()
class FlagWithAllowedHelp {
  @CliOption(allowedHelp: {})
  bool option;
}

@ShouldThrow('Could not handle field `option`. '
    '`valueHelp` is not supported for flags.')
@CliOptions()
class FlagWithValueHelp {
  @CliOption(valueHelp: 'string')
  bool option;
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
  ArgResults command;
}

@ShouldGenerate(r'''
SpecialNotAnnotated _$parseSpecialNotAnnotatedResult(ArgResults result) =>
    SpecialNotAnnotated()
      ..option = result['option'] as String
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
  String option;
  bool rest;
  ArgResults command;
  bool optionWasParsed;
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
  ArgResults command;
}

ArgResults _stringToArgsResults(String value) => null;

@ShouldThrow('Could not handle field `nothingWasParsed`. Could not find '
    'expected source field `nothing`.')
@CliOptions()
class LonelyWasParsed {
  bool nothingWasParsed;
}

@ShouldThrow(
    'Could not handle field `command`. `ArgResults` is not a supported type.')
@CliOptions()
class AnnotatedCommandNoParser {
  @CliOption()
  ArgResults command;
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
Object annotatedMethod() => null;
