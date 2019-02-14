import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'default_override_example.g.dart';

const _defaultConfig = 'release';
const _defaultConfigFile = 'build.$_defaultConfig.yaml';
const _directoryFlag = 'directory';

ArgParser get prettyParser =>
    _$populateDefaultOverrideOptionsParser(ArgParser(usageLineLength: 80));

@CliOptions()
class DefaultOverrideOptions {
  @CliOption(
    name: _directoryFlag,
    abbr: 'd',
    defaultsTo: 'web',
    provideDefaultToOverride: true,
  )
  final String directory;

  @CliOption(
    abbr: 'b',
    defaultsTo: 'gh-pages',
    provideDefaultToOverride: true,
  )
  final String branch;

  @CliOption(
    defaultsTo: PubBuildMode.release,
    help: 'The mode to run `pub build` in.',
    provideDefaultToOverride: true,
  )
  final PubBuildMode mode;
  final bool modeWasParsed;

  @CliOption(
    abbr: 'c',
    help: 'The configuration to use when running `build_runner`. '
        'If this option is not set, `$_defaultConfig` is used if '
        '`$_defaultConfigFile` exists in the current directory.',
    provideDefaultToOverride: true,
  )
  final String buildConfig;

  final bool buildConfigWasParsed;

  @CliOption(
    abbr: 'm',
    defaultsTo: 'Built <$_directoryFlag>',
    provideDefaultToOverride: true,
  )
  final String message;

  @CliOption(
    abbr: 't',
    help: 'If `$_defaultConfigFile` exists in the current directory, defaults'
        ' to "build". Otherwise, "pub".',
    provideDefaultToOverride: true,
  )
  final BuildTool buildTool;

  @CliOption(
    provideDefaultToOverride: true,
  )
  final BazelOptions bazelOptions;

  @CliOption(
    abbr: 'h',
    negatable: false,
    help: 'Prints usage information. Which is so "\$" you don\'t even know it!',
    provideDefaultToOverride: true,
  )
  final bool help;

  @CliOption(
    hide: true,
    provideDefaultToOverride: true,
  )
  final bool secret;

  @CliOption(
    defaultsTo: true,
    negatable: true,
    provideDefaultToOverride: true,
  )
  final bool release;

  final List<String> rest;

  @CliOption(convert: _convert)
  Duration maxRuntime;

  // Explicitly not used – to validate logging behavior
  final String coolBean = null;

  ArgResults command;

  DefaultOverrideOptions({
    this.directory,
    this.branch,
    this.mode,
    this.modeWasParsed,
    this.buildConfig,
    this.buildConfigWasParsed,
    this.message,
    this.buildTool,
    this.help,
    this.bazelOptions,
    this.release,
    this.secret,
    this.rest,
  });
}

Duration _convert(String source) {
  if (source == null) {
    return null;
  }

  final seconds = int.tryParse(source);

  if (seconds == null) {
    throw FormatException(
        'The value provided for "max-runtime" – "$source" – was not a number.');
  }

  return Duration(seconds: seconds);
}

enum BuildTool { pub, build }

enum PubBuildMode { release, debug }

enum BazelOptions { toSource, fromSource, viaAssets }
