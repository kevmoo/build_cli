// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_helper_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(String enumName, List<T> values, String enumValue) =>
    enumValue == null
        ? null
        : values.singleWhere((e) => e.toString() == '$enumName.$enumValue',
            orElse: () => throw StateError(
                'Could not find the value `$enumValue` in enum `$enumName`.'));

T _$badNumberFormat<T extends num>(
        String source, String type, String argName) =>
    throw FormatException(
        'Cannot parse "$source" into `$type` for option "$argName".');

FirstOptions _$parseFirstOptionsResult(ArgResults result) => FirstOptions()
  ..value = _$enumValueHelper(
      'OptionValue', OptionValue.values, result['value'] as String)
  ..count = int.tryParse(result['count'] as String) ??
      _$badNumberFormat(result['count'] as String, 'int', 'count');

ArgParser _$populateFirstOptionsParser(ArgParser parser) =>
    parser..addOption('value', allowed: ['a', 'b', 'c'])..addOption('count');

final _$parserForFirstOptions = _$populateFirstOptionsParser(ArgParser());

FirstOptions parseFirstOptions(List<String> args) {
  final result = _$parserForFirstOptions.parse(args);
  return _$parseFirstOptionsResult(result);
}

SecondOptions _$parseSecondOptionsResult(ArgResults result) => SecondOptions()
  ..value = _$enumValueHelper(
      'OptionValue', OptionValue.values, result['value'] as String)
  ..count = int.tryParse(result['count'] as String) ??
      _$badNumberFormat(result['count'] as String, 'int', 'count');

ArgParser _$populateSecondOptionsParser(ArgParser parser) =>
    parser..addOption('value', allowed: ['a', 'b', 'c'])..addOption('count');

final _$parserForSecondOptions = _$populateSecondOptionsParser(ArgParser());

SecondOptions parseSecondOptions(List<String> args) {
  final result = _$parserForSecondOptions.parse(args);
  return _$parseSecondOptionsResult(result);
}
