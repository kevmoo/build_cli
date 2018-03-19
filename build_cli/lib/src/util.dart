import 'package:logging/logging.dart';

void warn(Object message) => _logger.warning(message);

final _logger = new Logger('ArgsGenerator');
