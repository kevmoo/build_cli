import 'package:logging/logging.dart';

void warn(Object message) => _logger.warning(message);

final _logger = new Logger('ArgsGenerator');

final _upperCase = new RegExp('[A-Z]');

String kebab(String input) => input.replaceAllMapped(_upperCase, (match) {
      var lower = match.group(0).toLowerCase();

      if (match.start > 0) {
        lower = '-$lower';
      }

      return lower;
    });
