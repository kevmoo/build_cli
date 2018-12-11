// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(String enumName, List<T> values, String enumValue) =>
    enumValue == null
        ? null
        : values.singleWhere((e) => e.toString() == '$enumName.$enumValue',
            orElse: () => throw StateError(
                'Could not find the value `$enumValue` in enum `$enumName`.'));

Options _$parseOptionsResult(ArgResults result) =>
    Options(result['name'] as String, nameWasParsed: result.wasParsed('name'))
      ..yell = result['yell'] as bool
      ..displayLanguage = _$enumValueHelper(
          'Language', Language.values, result['display-language'] as String)
      ..help = result['help'] as bool;

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption('name',
      abbr: 'n', help: 'Required. The name to use in the greeting.')
  ..addFlag('yell')
  ..addOption('display-language',
      abbr: 'l', defaultsTo: 'en', allowed: ['en', 'es'])
  ..addFlag('help', help: 'Prints usage information.', negatable: false);

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
