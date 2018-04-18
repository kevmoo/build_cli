// GENERATED CODE - DO NOT MODIFY BY HAND
// You can customize this header by setting the `header` option
// in `build.yaml`.

part of 'peanut_example.dart';

// **************************************************************************
// Generator: CliGenerator
// **************************************************************************

PeanutOptions _$parsePeanutOptionsResult(ArgResults result) {
  T enumValueHelper<T>(String enumName, List<T> values, String enumValue) =>
      enumValue == null
          ? null
          : values.singleWhere((e) => e.toString() == '$enumName.$enumValue',
              orElse: () => throw new StateError(
                  'Could not find the value `$enumValue` in enum `$enumName`.'));

  return new PeanutOptions(
      directory: result['directory'] as String,
      branch: result['branch'] as String,
      mode: enumValueHelper(
          'PubBuildMode', PubBuildMode.values, result['mode'] as String),
      modeWasParsed: result.wasParsed('mode'),
      buildConfig: result['build-config'] as String,
      buildConfigWasParsed: result.wasParsed('build-config'),
      message: result['message'] as String,
      buildTool: enumValueHelper(
          'BuildTool', BuildTool.values, result['build-tool'] as String),
      help: result['help'] as bool,
      bazelOptions: enumValueHelper('BazelOptions', BazelOptions.values,
          result['bazel-options'] as String),
      release: result['release'] as bool,
      secret: result['secret'] as bool,
      rest: result.rest)
    ..maxRuntime = _convert(result['max-runtime'] as String);
}

ArgParser _$populatePeanutOptionsParser(ArgParser parser) => parser
  ..addOption('directory', abbr: 'd', defaultsTo: 'web')
  ..addOption('branch', abbr: 'b', defaultsTo: 'gh-pages')
  ..addOption('mode',
      help: 'The mode to run `pub build` in.',
      defaultsTo: 'release',
      allowed: ['release', 'debug'])
  ..addOption('build-config',
      abbr: 'c',
      help:
          'The configuration to use when running `build_runner`. If this option is not set, `release` is used if `build.release.yaml` exists in the current directory.')
  ..addOption('message', abbr: 'm', defaultsTo: 'Built <directory>')
  ..addOption('build-tool',
      abbr: 't',
      help: 'If `build.release.yaml` exists in the current directory, defaults to "build". Otherwise, "pub".',
      allowed: [
        'pub',
        'build'
      ])
  ..addOption('bazel-options',
      allowed: ['to-source', 'from-source', 'via-assets'])
  ..addFlag('help',
      abbr: 'h',
      help:
          'Prints usage information. Which is so \"\$\" you don\'t even know it!',
      negatable: false)
  ..addFlag('secret', hide: true)
  ..addFlag('release', defaultsTo: true, negatable: true)
  ..addOption('max-runtime');

final _$parserForPeanutOptions = _$populatePeanutOptionsParser(new ArgParser());

PeanutOptions parsePeanutOptions(List<String> args) {
  var result = _$parserForPeanutOptions.parse(args);
  return _$parsePeanutOptionsResult(result);
}
