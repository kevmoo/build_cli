import 'package:args/args.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'peanut_example.g.dart';

const _defaultConfig = 'release';
const _defaultConfigFile = 'build.$_defaultConfig.yaml';
const _directoryFlag = 'directory';

ArgParser get parser => _$parserForPeanutOptions;

@CliOptions()
class PeanutOptions {
  @CliOption(name: _directoryFlag, abbr: 'd', defaultsTo: 'web')
  final String directory;

  @CliOption(abbr: 'b', defaultsTo: 'gh-pages')
  final String branch;

  @CliOption(
      defaultsTo: PubBuildMode.release, help: 'The mode to run `pub build` in.')
  final PubBuildMode mode;

  @CliOption(
      abbr: 'c',
      help: 'The configuration to use when running `build_runner`. '
          'If this option is not set, `$_defaultConfig` is used if '
          '`$_defaultConfigFile` exists in the current directory.')
  final String buildConfig;

  @CliOption(abbr: 'm', defaultsTo: 'Built <$_directoryFlag>')
  final String message;

  @CliOption(
      abbr: 't',
      help: 'If `$_defaultConfigFile` exists in the current directory, defaults'
          ' to "build". Otherwise, "pub".')
  final BuildTool buildTool;

  @CliOption(abbr: 'h', negatable: false, help: 'Prints usage information.')
  final bool help;

  PeanutOptions(
      {this.directory,
      this.branch,
      this.mode,
      this.buildConfig,
      this.message,
      this.buildTool,
      this.help});
}

enum BuildTool { pub, build }

enum PubBuildMode { release, debug }
