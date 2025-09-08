// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, require_trailing_commas

part of 'peanut_example.dart';

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

T? _$nullableEnumValueHelperNullable<T>(
  Map<T, String> enumValues,
  String? source,
) => source == null ? null : _$enumValueHelper(enumValues, source);

PeanutOptions _$parsePeanutOptionsResult(ArgResults result) =>
    PeanutOptions(
        bazelOptions: _$enumValueHelper(
          _$BazelOptionsEnumMapBuildCli,
          result['bazel-options'] as String,
        ),
        branch: result['branch'] as String,
        buildConfigWasParsed: result.wasParsed('build-config'),
        debugBuildTool: _$enumValueHelper(
          _$BuildToolEnumMapBuildCli,
          result['debug-build-tool'] as String,
        ),
        directory: result['directory'] as String,
        help: result['help'] as bool,
        message: result['message'] as String,
        mode: _$enumValueHelper(
          _$PubBuildModeEnumMapBuildCli,
          result['mode'] as String,
        ),
        modeWasParsed: result.wasParsed('mode'),
        release: result['release'] as bool,
        rest: result.rest,
        secret: result['secret'] as bool,
        minRuntime: _convertNotNull(result['min-runtime'] as String),
        buildConfig: result['build-config'] as String?,
        buildTool: _$nullableEnumValueHelperNullable(
          _$BuildToolEnumMapBuildCli,
          result['build-tool'] as String?,
        ),
      )
      ..maxRuntime = _convert(result['max-runtime'] as String?)
      ..command = result.command;

const _$PubBuildModeEnumMapBuildCli = <PubBuildMode, String>{
  PubBuildMode.release: 'release',
  PubBuildMode.debug: 'debug',
};

const _$BuildToolEnumMapBuildCli = <BuildTool, String>{
  BuildTool.pub: 'pub',
  BuildTool.build: 'build',
  BuildTool.$loco: r'$loco',
};

const _$BazelOptionsEnumMapBuildCli = <BazelOptions, String>{
  BazelOptions.toSource: 'to-source',
  BazelOptions.fromSource: 'from-source',
  BazelOptions.viaAssets: 'via-assets',
};

ArgParser _$populatePeanutOptionsParser(ArgParser parser) => parser
  ..addOption('directory', abbr: 'd', defaultsTo: 'web')
  ..addOption('branch', abbr: 'b', defaultsTo: 'gh-pages')
  ..addOption(
    'mode',
    help: 'The mode to run `pub build` in.',
    defaultsTo: 'release',
    allowed: ['release', 'debug'],
  )
  ..addOption(
    'build-config',
    abbr: 'c',
    help:
        'The configuration to use when running `build_runner`. If this option is not set, `release` is used if `build.release.yaml` exists in the current directory.',
  )
  ..addOption('message', abbr: 'm', defaultsTo: 'Built <directory>')
  ..addOption(
    'build-tool',
    abbr: 't',
    help:
        'If `build.release.yaml` exists in the current directory, defaults to "build". Otherwise, "pub".',
    allowed: ['pub', 'build', r'$loco'],
  )
  ..addOption(
    'debug-build-tool',
    help: 'The build tool to use for debugging.',
    defaultsTo: r'$loco',
    allowed: ['pub', 'build', r'$loco'],
  )
  ..addOption(
    'bazel-options',
    help: 'nice options',
    defaultsTo: 'to-source',
    allowed: ['to-source', 'from-source', 'via-assets'],
  )
  ..addFlag(
    'help',
    abbr: 'h',
    help: 'Prints usage information. Which is so "\$" you don\'t even know it!',
    negatable: false,
  )
  ..addFlag('secret', hide: true)
  ..addFlag('release', defaultsTo: true)
  ..addOption('max-runtime')
  ..addOption('min-runtime', defaultsTo: '0');

final _$parserForPeanutOptions = _$populatePeanutOptionsParser(ArgParser());

PeanutOptions parsePeanutOptions(List<String> args) {
  final result = _$parserForPeanutOptions.parse(args);
  return _$parsePeanutOptionsResult(result);
}
