// @dart=2.12

import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'pubviz_example.g.dart';

ArgParser get prettyParser =>
    _$populatePubvizOptionsParser(ArgParser(usageLineLength: 80));

@CliOptions()
class PubvizOptions {
  @CliOption(
      abbr: 'f',
      defaultsTo: FormatOptions.html,
      allowedHelp: _formatOptionsHelp)
  final FormatOptions format;

  @CliOption(hide: true)
  final String? secret;

  @CliOption(
      abbr: 'i',
      help: 'A comma seperated list of packages to exclude in the output.')
  final List<String>? ignorePackages;

  @CliOption(defaultsTo: 8080, valueHelp: 'PORT')
  final int productionPort;

  @CliOption(defaultsTo: 3.14)
  num numValue;

  @CliOption(defaultsTo: 3e3)
  double doubleValue;

  @CliOption(defaultsTo: 8080, allowed: [
    8080,
    9090,
    42
  ], allowedHelp: {
    8080: 'the cool port',
    9090: 'the alt port',
    42: 'the knowledge port'
  })
  int devPort;

  List? listOfNothing;
  List<dynamic>? listOfDynamic;
  List<Object>? listOfObject;

  //TODO: support List<num>
  //List<int> listenPorts;

  PubvizOptions({
    required this.format,
    required this.productionPort,
    required this.devPort,
    required this.doubleValue,
    required this.numValue,
    this.secret,
    this.ignorePackages,
  });
}

enum FormatOptions { dot, html }

const _formatOptionsHelp = <FormatOptions, String>{
  FormatOptions.dot: "Generate a GraphViz 'dot' file.",
  FormatOptions.html:
      'Wrap the GraphViz dot format in an HTML template which renders it.'
};
