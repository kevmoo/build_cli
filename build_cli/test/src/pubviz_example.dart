import 'package:args/args.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'pubviz_example.g.dart';

ArgParser get parser => _$parserForPeanutOptions;

@CliOptions()
class PeanutOptions {
  @CliOption(
      abbr: 'f',
      defaultsTo: FormatOptions.html,
      allowedHelp: _formatOptionsHelp)
  final FormatOptions format;

  @CliOption(hide: true)
  final String secret;

  PeanutOptions({this.format, this.secret});
}

enum FormatOptions { dot, html }

const _formatOptionsHelp = const <FormatOptions, String>{
  FormatOptions.dot: 'Generate a GraphViz dot file',
  FormatOptions.html:
      'Wrap the GraphViz dot format in an HTML template which renders it.'
};
