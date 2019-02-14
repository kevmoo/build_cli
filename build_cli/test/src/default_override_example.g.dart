// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_override_example.dart';

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

DefaultOverrideOptions _$parseDefaultOverrideOptionsResult(ArgResults result) =>
    DefaultOverrideOptions(
        directory: result['directory'] as String,
        branch: result['branch'] as String,
        mode:
            _$enumValueHelper(_$PubBuildModeEnumMap, result['mode'] as String),
        modeWasParsed: result.wasParsed('mode'),
        buildConfig: result['build-config'] as String,
        buildConfigWasParsed: result.wasParsed('build-config'),
        message: result['message'] as String,
        buildTool: _$enumValueHelper(
            _$BuildToolEnumMap, result['build-tool'] as String),
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
  BuildTool.build: 'build'
};

const _$BazelOptionsEnumMap = <BazelOptions, String>{
  BazelOptions.toSource: 'to-source',
  BazelOptions.fromSource: 'from-source',
  BazelOptions.viaAssets: 'via-assets'
};

ArgParser _$populateDefaultOverrideOptionsParser(
  ArgParser parser, {
  String directoryDefaultOverride,
  String branchDefaultOverride,
  PubBuildMode modeDefaultOverride,
  String buildConfigDefaultOverride,
  String messageDefaultOverride,
  BuildTool buildToolDefaultOverride,
  BazelOptions bazelOptionsDefaultOverride,
  bool helpDefaultOverride,
  bool secretDefaultOverride,
  bool releaseDefaultOverride,
}) =>
    parser
      ..addOption('directory',
          abbr: 'd', defaultsTo: directoryDefaultOverride ?? 'web')
      ..addOption('branch',
          abbr: 'b', defaultsTo: branchDefaultOverride ?? 'gh-pages')
      ..addOption('mode',
          help: 'The mode to run `pub build` in.',
          defaultsTo: _$PubBuildModeEnumMap[modeDefaultOverride] ?? 'release',
          allowed: ['release', 'debug'])
      ..addOption('build-config',
          abbr: 'c',
          help:
              'The configuration to use when running `build_runner`. If this option is not set, `release` is used if `build.release.yaml` exists in the current directory.',
          defaultsTo: buildConfigDefaultOverride)
      ..addOption('message',
          abbr: 'm', defaultsTo: messageDefaultOverride ?? 'Built <directory>')
      ..addOption('build-tool',
          abbr: 't',
          help: 'If `build.release.yaml` exists in the current directory, defaults to "build". Otherwise, "pub".',
          defaultsTo: _$BuildToolEnumMap[buildToolDefaultOverride],
          allowed: [
            'pub',
            'build'
          ])
      ..addOption('bazel-options',
          defaultsTo: _$BazelOptionsEnumMap[bazelOptionsDefaultOverride],
          allowed: ['to-source', 'from-source', 'via-assets'])
      ..addFlag('help',
          abbr: 'h',
          help:
              'Prints usage information. Which is so \"\$\" you don\'t even know it!',
          defaultsTo: helpDefaultOverride,
          negatable: false)
      ..addFlag('secret', defaultsTo: secretDefaultOverride, hide: true)
      ..addFlag('release',
          defaultsTo: releaseDefaultOverride ?? true, negatable: true)
      ..addOption('max-runtime');

final _$parserForDefaultOverrideOptions =
    _$populateDefaultOverrideOptionsParser(ArgParser());

DefaultOverrideOptions parseDefaultOverrideOptions(List<String> args) {
  final result = _$parserForDefaultOverrideOptions.parse(args);
  return _$parseDefaultOverrideOptionsResult(result);
}
