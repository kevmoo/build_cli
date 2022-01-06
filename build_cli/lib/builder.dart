/// Configuration for using `package:build`-compatible build systems.
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline.
///
/// See [package:build_runner](https://pub.dev/packages/build_runner)
/// for more information.
library builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/build_cli_generator.dart';

Builder buildCli(BuilderOptions options) {
  if (options.config.isNotEmpty) {
    log.warning(
      'These options were ignored: `${options.config.keys.join(', ')}`.',
    );
  }

  return SharedPartBuilder(
    const [
      CliGenerator(),
    ],
    'build_cli',
  );
}
