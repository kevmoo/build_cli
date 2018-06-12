// GENERATED CODE - DO NOT MODIFY BY HAND
// You can customize this header by setting the `header` option
// in `build.yaml`.

part of 'example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

Options _$parseOptionsResult(ArgResults result) {
  T enumValueHelper<T>(String enumName, List<T> values, String enumValue) =>
      enumValue == null
          ? null
          : values.singleWhere((e) => e.toString() == '$enumName.$enumValue',
              orElse: () => throw new StateError(
                  'Could not find the value `$enumValue` in enum `$enumName`.'));

  return new Options(result['name'] as String,
      nameWasParsed: result.wasParsed('name'))
    ..yell = result['yell'] as bool
    ..displayLanguage = enumValueHelper(
        'Language', Language.values, result['display-language'] as String)
    ..help = result['help'] as bool;
}

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption('name',
      abbr: 'n', help: 'Required. The name to use in the greeting.')
  ..addFlag('yell')
  ..addOption('display-language',
      abbr: 'l', defaultsTo: 'en', allowed: ['en', 'es'])
  ..addFlag('help', help: 'Prints usage information.', negatable: false);

final _$parserForOptions = _$populateOptionsParser(new ArgParser());

Options parseOptions(List<String> args) {
  var result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
