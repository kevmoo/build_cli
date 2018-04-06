[![Build Status](https://travis-ci.org/kevmoo/build_cli.svg?branch=master)](https://travis-ci.org/kevmoo/build_cli)

Parse command line arguments directly into an annotation class
using the power of the [Dart build system](https://github.com/dart-lang/build) 
and [source_gen](https://pub.dartlang.org/packages/source_gen).

# Setup

Add three packages to `pubspec.yaml`:

```yaml
dependencies:
  build_cli_annotations: ^0.1.0

dev_dependencies:
  build_cli: ^0.2.0
  build_runner: '>=0.7.10 <0.9.0'
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

Uses [package:args](https://pub.dartlang.org/packages/args) under the covers.

At the moment, this project is very light on documentation and tests.
The `test` directory contains some
[examples](https://github.com/kevmoo/build_cli/tree/master/build_cli/test/src)
for inspiration.

Also look at the
[`package:peanut` source code](https://github.com/kevmoo/peanut.dart).
The `options` files in the 
[`src` directory](https://github.com/kevmoo/peanut.dart/tree/master/lib/src)
as the interesting files.
