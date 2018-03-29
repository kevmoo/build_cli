import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

import 'src/build_cli_generator.dart';

// TODO: until we can use `log` here - github.com/dart-lang/build/issues/1223
final _logger = new Logger('json_serializable');

Builder cliBuilder(BuilderOptions options) {
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
