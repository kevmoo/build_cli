export 'package:args/args.dart' show ArgParser, ArgResults;

class CliOptions {
  const CliOptions();
}

class CliOption {
  final String name;
  final String abbr;
  final Object defaultsTo;
  final String help;
  final List<Object> allowed;
  final Map<Object, String> allowedHelp;
  final bool negatable;
  final bool hide;

  const CliOption(
      {this.name,
      this.abbr,
      this.defaultsTo,
      this.help,
      this.allowed,
      this.negatable,
      this.allowedHelp,
      this.hide});
}
