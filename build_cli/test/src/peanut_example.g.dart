// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peanut_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(Map<T, String> enumValues, String source) {
  if (source == null) {
    return null;
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

PeanutOptions _$parsePeanutOptionsResult(ArgResults result) => PeanutOptions(
    directory: result['directory'] as String,
    branch: result['branch'] as String,
    mode: _$enumValueHelper(_$PubBuildModeEnumMap, result['mode'] as String),
    modeWasParsed: result.wasParsed('mode'),
    buildConfig: result['build-config'] as String,
    buildConfigWasParsed: result.wasParsed('build-config'),
    message: result['message'] as String,
    buildTool:
        _$enumValueHelper(_$BuildToolEnumMap, result['build-tool'] as String),
    help: result['help'] as bool,
    bazelOptions: _$enumValueHelper(
        _$BazelOptionsEnumMap, result['bazel-options'] as String),
    release: result['release'] as bool,
    secret: result['secret'] as bool,
    rest: result.rest)
  ..maxRuntime = _convert(result['max-runtime'] as String)
  ..command = result.command;

const _$PubBuildModeEnumMap = <PubBuildMode, String>{
  PubBuildMode.release: 'release',
  PubBuildMode.debug: 'debug'
};

const _$BuildToolEnumMap = <BuildTool, String>{
  BuildTool.pub: 'pub',
  BuildTool.build: 'build',
  BuildTool.$loco: r'$loco'
};

const _$BazelOptionsEnumMap = <BazelOptions, String>{
  BazelOptions.toSource: 'to-source',
  BazelOptions.fromSource: 'from-source',
  BazelOptions.viaAssets: 'via-assets'
};

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
        'build',
        r'$loco'
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

final _$parserForPeanutOptions = _$populatePeanutOptionsParser(ArgParser());

PeanutOptions parsePeanutOptions(List<String> args) {
  final result = _$parserForPeanutOptions.parse(args);
  return _$parsePeanutOptionsResult(result);
}
