// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_helper_example.dart';

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

FirstOptions _$parseFirstOptionsResult(ArgResults result) {
  return new FirstOptions()
    ..value = _$enumValueHelper(
        'OptionValue', OptionValue.values, result['value'] as String)
    ..count = int.tryParse(result['count'] as String) ??
        _$badNumberFormat(result['count'] as String, 'int', 'count');
}

ArgParser _$populateFirstOptionsParser(ArgParser parser) =>
    parser..addOption('value', allowed: ['a', 'b', 'c'])..addOption('count');

final _$parserForFirstOptions = _$populateFirstOptionsParser(new ArgParser());

FirstOptions parseFirstOptions(List<String> args) {
  var result = _$parserForFirstOptions.parse(args);
  return _$parseFirstOptionsResult(result);
}

SecondOptions _$parseSecondOptionsResult(ArgResults result) {
  return new SecondOptions()
    ..value = _$enumValueHelper(
        'OptionValue', OptionValue.values, result['value'] as String)
    ..count = int.tryParse(result['count'] as String) ??
        _$badNumberFormat(result['count'] as String, 'int', 'count');
}

ArgParser _$populateSecondOptionsParser(ArgParser parser) =>
    parser..addOption('value', allowed: ['a', 'b', 'c'])..addOption('count');

final _$parserForSecondOptions = _$populateSecondOptionsParser(new ArgParser());

SecondOptions parseSecondOptions(List<String> args) {
  var result = _$parserForSecondOptions.parse(args);
  return _$parseSecondOptionsResult(result);
}
