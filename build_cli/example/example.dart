import 'dart:io';

import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'example.g.dart';

/// Annotation your option class with [CliOptions].
@CliOptions()
class Options {
  /// Customize options and flags by annotating fields with [CliOption].
  @CliOption(abbr: 'n', help: 'Required. The name to use in the greeting.')
  final String name;

  /// Name a field `[name]WasParsed` without a [CliOption] annotation and it
  /// will be populated with `ArgResult.wasParsed('name')`.
  final bool nameWasParsed;

  /// [bool] fields are turned into flags.
  ///
  /// Fields without the [CliOption] annotation are picked up with simple
  /// defaults.
  late bool yell;

  /// Field names are also "kebab cased" automatically.
  ///
  /// This becomes `--display-language`.
  @CliOption(defaultsTo: Language.en, abbr: 'l')
  late Language displayLanguage;

  @CliOption(negatable: false, help: 'Prints usage information.')
  late bool help;

  /// Populates final and non-null fields as long as there are matching
  /// constructor parameters.
  Options(this.name, {this.nameWasParsed = false});
}

/// Enums are a great way to specify options with a fixed set of allowed
/// values.
enum Language { en, es }

void main(List<String> args) {
  Options options;
  try {
    options = parseOptions(args);
    if (!options.nameWasParsed) {
      throw const FormatException('You must provide a name.');
    }
  } on FormatException catch (e) {
    print(e.message);
    print('');
    _printUsage();
    exitCode = 64;
    return;
  }

  if (options.help) {
    _printUsage();
    return;
  }

  final buffer = StringBuffer();

  switch (options.displayLanguage) {
    case Language.en:
      buffer.write('Hello, ');
    case Language.es:
      buffer.write('¡Hola, ');
  }

  buffer
    ..write(options.name)
    ..write('!');

  if (options.yell) {
    print(buffer.toString().toUpperCase());
  } else {
    print(buffer);
  }
}

void _printUsage() {
  print('Usage: example/example.dart [arguments]');
  print(_$parserForOptions.usage);
}
