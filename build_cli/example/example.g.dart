// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, require_trailing_commas

part of 'example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(Map<T, String> enumValues, String source) => enumValues
    .entries
    .singleWhere(
      (e) => e.value == source,
      orElse: () => throw ArgumentError(
        '`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}',
      ),
    )
    .key;

Options _$parseOptionsResult(ArgResults result) =>
    Options(result['name'] as String, nameWasParsed: result.wasParsed('name'))
      ..yell = result['yell'] as bool
      ..displayLanguage = _$enumValueHelper(
        _$LanguageEnumMapBuildCli,
        result['display-language'] as String,
      )
      ..help = result['help'] as bool;

const _$LanguageEnumMapBuildCli = <Language, String>{
  Language.en: 'en',
  Language.es: 'es',
};

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption(
    'name',
    abbr: 'n',
    help: 'Required. The name to use in the greeting.',
  )
  ..addFlag('yell')
  ..addOption(
    'display-language',
    abbr: 'l',
    defaultsTo: 'en',
    allowed: ['en', 'es'],
  )
  ..addFlag('help', help: 'Prints usage information.', negatable: false);

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
