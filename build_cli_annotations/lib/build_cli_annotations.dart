export 'package:args/args.dart' show ArgParser, ArgResults;

class CliOptions {
  const CliOptions();
}

class CliOption {
  final String name;
  final String abbr;
  final Object defaultsTo;
  final String help;
  final String valueHelp;
  final List<Object> allowed;
  final Map<Object, String> allowedHelp;
  final bool negatable;
  final bool hide;
  final bool nullable;
  final bool provideDefaultToOverride;

  /// A top-level [Function] that converts an option value into the destination
  /// type.
  final dynamic Function(String)? convert;

  const CliOption(
      {required this.name,
       required this.abbr,
        required this.defaultsTo,
        required this.help,
        required this.valueHelp,
        required this.allowed,
        required this.negatable,
        required this.allowedHelp,
        required this.hide,
        this.convert,
        required this.nullable,
        this.provideDefaultToOverride = false});
}
