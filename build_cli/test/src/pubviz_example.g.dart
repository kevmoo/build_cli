// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubviz_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(String enumName, List<T> values, String enumValue) =>
    enumValue == null
        ? null
        : values.singleWhere((e) => e.toString() == '$enumName.$enumValue',
            orElse: () => throw new StateError(
                'Could not find the value `$enumValue` in enum `$enumName`.'));

T _$badNumberFormat<T extends num>(
        String source, String type, String argName) =>
    throw new FormatException(
        'Cannot parse "$source" into `$type` for option "$argName".');

PeanutOptions _$parsePeanutOptionsResult(ArgResults result) =>
    new PeanutOptions(
        format: _$enumValueHelper(
            'FormatOptions', FormatOptions.values, result['format'] as String),
        secret: result['secret'] as String,
        ignorePackages: result['ignore-packages'] as List<String>,
        productionPort: int.tryParse(result['production-port'] as String) ??
            _$badNumberFormat(
                result['production-port'] as String, 'int', 'production-port'))
      ..numValue = num.tryParse(result['num-value'] as String) ??
          _$badNumberFormat(result['num-value'] as String, 'num', 'num-value')
      ..doubleValue = double.tryParse(result['double-value'] as String) ??
          _$badNumberFormat(
              result['double-value'] as String, 'double', 'double-value')
      ..devPort = int.tryParse(result['dev-port'] as String) ??
          _$badNumberFormat(result['dev-port'] as String, 'int', 'dev-port')
      ..listOfNothing = result['list-of-nothing'] as List
      ..listOfDynamic = result['list-of-dynamic'] as List
      ..listOfObject = result['list-of-object'] as List;

ArgParser _$populatePeanutOptionsParser(ArgParser parser) => parser
  ..addOption('format', abbr: 'f', defaultsTo: 'html', allowed: [
    'dot',
    'html'
  ], allowedHelp: <String, String>{
    'dot': "Generate a GraphViz 'dot' file.",
    'html': 'Wrap the GraphViz dot format in an HTML template which renders it.'
  })
  ..addOption('secret', hide: true)
  ..addMultiOption('ignore-packages',
      abbr: 'i',
      help: 'A comma seperated list of packages to exclude in the output.')
  ..addOption('production-port', valueHelp: 'PORT', defaultsTo: '8080')
  ..addOption('num-value', defaultsTo: '3.14')
  ..addOption('double-value', defaultsTo: '3000.0')
  ..addOption('dev-port', defaultsTo: '8080', allowed: [
    '8080',
    '9090',
    '42'
  ], allowedHelp: <String, String>{
    '8080': 'the cool port',
    '9090': 'the alt port',
    '42': 'the knowledge port'
  })
  ..addMultiOption('list-of-nothing')
  ..addMultiOption('list-of-dynamic')
  ..addMultiOption('list-of-object');

final _$parserForPeanutOptions = _$populatePeanutOptionsParser(new ArgParser());

PeanutOptions parsePeanutOptions(List<String> args) {
  var result = _$parserForPeanutOptions.parse(args);
  return _$parsePeanutOptionsResult(result);
}
