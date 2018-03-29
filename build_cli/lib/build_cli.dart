/// Configuration for using `package:build`-compatible build systems.
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline.
///
/// See [package:build_runner](https://pub.dartlang.org/packages/build_runner)
/// for more information.
library build_cli;

import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

import 'src/build_cli_generator.dart';

export 'src/build_cli_generator.dart';

// TODO: until we can use `log` here - github.com/dart-lang/build/issues/1223
final _logger = new Logger('json_serializable');

/// Supports `package:build_runner` creation and configuration of `build_cli`.
///
/// Not meant to be invoked by hand-authored code.
Builder createBuilderForCliGenerator(BuilderOptions options) {
  // Paranoid copy of options.config - don't assume it's mutable or needed
  // elsewhere.
  var optionsMap = new Map<String, dynamic>.from(options.config);

  try {
    return _cliPartBuilder(header: optionsMap.remove('header') as String);
  } finally {
    if (optionsMap.isNotEmpty) {
      _logger.warning('These options were ignored: `$optionsMap`.');
    }
  }
}

Builder _cliPartBuilder({String header}) {
  return new PartBuilder(
    const [
      const CliGenerator(),
    ],
    header: header,
  );
}
