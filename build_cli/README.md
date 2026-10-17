[![Dart CI](https://github.com/kevmoo/build_cli/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/kevmoo/build_cli/actions/workflows/dart.yml?query=workflow%3Adart+branch%3Amaster)
[![Pub package](https://img.shields.io/pub/v/build_cli.svg)](https://pub.dev/packages/build_cli)
[![package publisher](https://img.shields.io/pub/publisher/build_cli.svg)](https://pub.dev/packages/build_cli/publisher)

Parse command line arguments directly into an annotation class using a
standalone CLI or the [Dart Build System][].

## Example

Annotate a class with `@CliOptions()` from [package:build_cli_annotations][].

```dart
import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'example.g.dart';

@CliOptions()
class Options {
  @CliOption(abbr: 'n', help: 'Required. The name to use in the greeting.')
  final String name;

  final bool nameWasParsed;

  late bool yell;

  @CliOption(defaultsTo: Language.en, abbr: 'l')
  late Language displayLanguage;

  @CliOption(negatable: false, help: 'Prints usage information.')
  late bool help;

  Options(this.name, {this.nameWasParsed = false});
}

enum Language { en, es }
```

Generate the `.g.dart` file with the standalone CLI (or [Dart Build System][])
to create helpers that parse command line arguments and populate your class.

```dart
void main(List<String> args) {
  var options = parseOptions(args);
  if (!options.nameWasParsed) {
    throw ArgumentError('You must set `name`.');
  }
  print(options.name);
}
```

## Setup

### Standalone CLI (Dart 3.12+)

Add only `build_cli_annotations` to `pubspec.yaml`:

```yaml
dependencies:
  build_cli_annotations: ^2.1.0
```

Run `build_cli` directly without adding `build_runner` to `dev_dependencies`:

```console
$ dart run build_cli@
$ dart run build_cli@ --check
```

Pass `--check` (`-c`) in CI to verify that all generated `.g.dart` files match
expected output without modifying disk. Pass optional file or directory paths
(`dart run build_cli@ bin/main.dart`) to limit which files are scanned (defaults
to `lib`, `bin`, `example`, `test`, and `tool`).

### With `build_runner`

If you combine multiple code generators in the same `.g.dart` file (such as
`package:json_serializable`), add `build_cli` and `build_runner` to
`dev_dependencies`:

```yaml
dependencies:
  build_cli_annotations: ^2.1.0

dev_dependencies:
  build_cli: ^2.3.0
  build_runner: ^2.10.0
```

- `build_cli_annotations` contains the annotations you add to classes and
  members to tell `build_cli` what to do.
  - If the code you're annotating is in a published directory – `lib`, `bin` –
    put it in `dependencies`.
- `build_cli` contains the logic to generate the code.
- `build_runner` coordinates running multiple builders into shared `.g.dart`
  files.

## Details

Uses [package:args](https://pub.dev/packages/args) under the covers.

## More examples

- The package contains a fully documented
  [end-to-end example](https://github.com/kevmoo/build_cli/tree/master/build_cli/example).
- The
  [test directory](https://github.com/kevmoo/build_cli/tree/master/build_cli/test/src)
  contains implementations that exercise most of the features of this package.
- Also look at the
  [`package:peanut` source code](https://github.com/kevmoo/peanut.dart). The
  `options` files in the
  [`src` directory](https://github.com/kevmoo/peanut.dart/tree/master/lib/src)
  are the interesting files.

[Dart Build System]: https://github.com/dart-lang/build
[package:build_cli_annotations]: https://pub.dev/packages/build_cli_annotations
