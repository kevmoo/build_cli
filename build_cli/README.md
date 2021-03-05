[![Dart CI](https://github.com/kevmoo/build_cli/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/kevmoo/build_cli/actions/workflows/dart.yml?query=workflow%3Adart+branch%3Amaster)
[![Pub package](https://img.shields.io/pub/v/build_cli.svg)](https://pub.dev/packages/build_cli)

Parse command line arguments directly into an annotation class using the 
[Dart Build System][].

# Example

Annotate a class with `@CliOptions()` from [package:build_cli_annotations][].

```dart
import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'example.g.dart';

@CliOptions()
class Options {
  @CliOption(abbr: 'n', help: 'Required. The name to use in the greeting.')
  final String name;

  final bool nameWasParsed;

  bool yell;

  @CliOption(defaultsTo: Language.en, abbr: 'l')
  Language displayLanguage;

  @CliOption(negatable: false, help: 'Prints usage information.')
  bool help;

  Options(this.name, {this.nameWasParsed});
}

enum Language { en, es }
```

Configure and run the [Dart Build System][] and a set of helpers is created
to parse the corresponding command line arguments and populate your class.

```dart
void main(List<String> args) {
  var options = parseOptions(args);
  if (!options.nameWasParsed) {
    throw new ArgumentError('You must set `name`.');
  }
  print(options.name);
}
```

# Setup

Add three packages to `pubspec.yaml`:

```yaml
dependencies:
  build_cli_annotations: ^1.0.0

dev_dependencies:
  build_cli: ^1.0.0
  build_runner: ^1.0.0
```

- `build_cli_annotations` is a separate package containing the annotations you
  add to classes and members to tell `build_cli` what to do.
    * If the code you're annotating is in a published directory – `lib`, `bin` –
      put it in the `dependencies` section.
- `build_cli` contains the logic to generate the code.
    * It should almost always be put in `dev_dependencies`.
- `build_runner` contains the logic to run a build and generate code.
    * It should almost always be put in `dev_dependencies`.

# Details

Uses [package:args](https://pub.dev/packages/args) under the covers.

# More examples:

- The package contains a fully documented
  [end-to-end example](https://github.com/kevmoo/build_cli/tree/master/build_cli/example).
- The [test directory](https://github.com/kevmoo/build_cli/tree/master/build_cli/test/src)
  contains implementations that exercise most of the features of this package.
- Also look at the
  [`package:peanut` source code](https://github.com/kevmoo/peanut.dart).
  The `options` files in the
  [`src` directory](https://github.com/kevmoo/peanut.dart/tree/master/lib/src)
  as the interesting files.

[Dart Build System]: https://github.com/dart-lang/build
[package:build_cli_annotations]: https://pub.dev/packages/build_cli_annotations
