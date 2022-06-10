import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:meta/meta_meta.dart';

export 'package:args/args.dart' show ArgParser, ArgResults;

/// Annotate classes with this type to create [ArgParser] helpers.
@Target({TargetKind.classType})
class CliOptions {
  /// If `true`, creates a [Command] abstract class associated with the
  /// annotated type.
  final bool createCommand;

  const CliOptions({
    this.createCommand = false,
  });
}

/// Annotate fields to configure the generated [ArgParser] helpers.
class CliOption {
  final String? name;
  final String? abbr;
  final Object? defaultsTo;
  final String? help;
  final String? valueHelp;
  final List<Object>? allowed;
  final Map<Object, String>? allowedHelp;
  final bool? negatable;
  final bool? hide;
  final bool provideDefaultToOverride;

  /// A top-level [Function] that converts an option value into the destination
  /// type.
  final dynamic Function(String)? convert;

  const CliOption({
    this.name,
    this.abbr,
    this.defaultsTo,
    this.help,
    this.valueHelp,
    this.allowed,
    this.negatable,
    this.allowedHelp,
    this.hide,
    this.convert,
    this.provideDefaultToOverride = false,
  });
}
