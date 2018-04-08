/// Configuration for using `package:build`-compatible build systems.
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline.
///
/// See [package:build_runner](https://pub.dartlang.org/packages/build_runner)
/// for more information.
library builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/build_cli_generator.dart';

Builder buildCli(BuilderOptions options) {
  // Paranoid copy of options.config - don't assume it's mutable or needed
  // elsewhere.
  var optionsMap = new Map<String, dynamic>.from(options.config);

  var builder = _cliPartBuilder(header: optionsMap.remove('header') as String);

  if (optionsMap.isNotEmpty) {
    if (log == null) {
      throw new StateError('Requires build_runner >=0.8.2 – please upgrade.');
    }
    log.warning('These options were ignored: `$optionsMap`.');
  }

  return builder;
}

Builder _cliPartBuilder({String header}) {
  return new PartBuilder(
    const [
      const CliGenerator(),
    ],
    header: header,
  );
}
