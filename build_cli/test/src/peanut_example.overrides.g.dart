// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'peanut_example.overrides.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

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

PeanutOptions _$parsePeanutOptionsResult(ArgResults result) => PeanutOptions(
    bazelOptions: _$enumValueHelper(
        _$BazelOptionsEnumMap, result['bazel-options'] as String),
    branch: result['branch'] as String,
    buildConfigWasParsed: result.wasParsed('build-config'),
    debugBuildTool: _$enumValueHelper(
        _$BuildToolEnumMap, result['debug-build-tool'] as String),
    directory: result['directory'] as String,
    help: result['help'] as bool,
    message: result['message'] as String,
    mode: _$enumValueHelper(_$PubBuildModeEnumMap, result['mode'] as String),
    modeWasParsed: result.wasParsed('mode'),
    release: result['release'] as bool,
    rest: result.rest,
    secret: result['secret'] as bool,
    minRuntime: _convertNotNull(result['min-runtime'] as String),
    buildConfig: result['build-config'] as String?,
    buildTool: _$nullableEnumValueHelperNullable(
        _$BuildToolEnumMap, result['build-tool'] as String?))
  ..maxRuntime = _convert(result['max-runtime'] as String?)
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

/// The value for [maxRuntimeDefaultOverride] must be a [String] that is convertible to [Duration].
/// The value for [minRuntimeDefaultOverride] must be a [String] that is convertible to [Duration].
ArgParser _$populatePeanutOptionsParser(
  ArgParser parser, {
  String? directoryDefaultOverride,
  String? branchDefaultOverride,
  PubBuildMode? modeDefaultOverride,
  String? buildConfigDefaultOverride,
  String? messageDefaultOverride,
  BuildTool? buildToolDefaultOverride,
  BuildTool? debugBuildToolDefaultOverride,
  BazelOptions? bazelOptionsDefaultOverride,
  bool? helpDefaultOverride,
  bool? secretDefaultOverride,
  bool? releaseDefaultOverride,
  String? maxRuntimeDefaultOverride,
  String? minRuntimeDefaultOverride,
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
            'build',
            r'$loco'
          ])
      ..addOption('debug-build-tool',
          help: 'The build tool to use for debugging.',
          defaultsTo:
              _$BuildToolEnumMap[debugBuildToolDefaultOverride] ?? r'$loco',
          allowed: ['pub', 'build', r'$loco'])
      ..addOption('bazel-options',
          help: 'nice options',
          defaultsTo:
              _$BazelOptionsEnumMap[bazelOptionsDefaultOverride] ?? 'to-source',
          allowed: ['to-source', 'from-source', 'via-assets'])
      ..addFlag('help',
          abbr: 'h',
          help:
              'Prints usage information. Which is so \"\$\" you don\'t even know it!',
          defaultsTo: helpDefaultOverride,
          negatable: false)
      ..addFlag('secret', defaultsTo: secretDefaultOverride, hide: true)
      ..addFlag('release', defaultsTo: releaseDefaultOverride ?? true)
      ..addOption('max-runtime', defaultsTo: maxRuntimeDefaultOverride)
      ..addOption('min-runtime', defaultsTo: minRuntimeDefaultOverride ?? '0');

final _$parserForPeanutOptions = _$populatePeanutOptionsParser(ArgParser());

PeanutOptions parsePeanutOptions(List<String> args) {
  final result = _$parserForPeanutOptions.parse(args);
  return _$parsePeanutOptionsResult(result);
}
