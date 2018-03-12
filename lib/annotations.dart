export 'package:args/args.dart' show ArgParser;

class CliOptions {
  const CliOptions();
}

class CliOption {
  final String name;
  final String abbr;
  final Object defaultsTo;
  final String help;
  final List<Object> allowed;
  final bool negatable;

  const CliOption(
      {this.name,
      this.abbr,
      this.defaultsTo,
      this.help,
      this.allowed,
      this.negatable});
}
