// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'undefined_boolean_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

NullableOptions _$parseNullableOptionsResult(ArgResults result) =>
    NullableOptions(result['nullable-option'] as bool?);

ArgParser _$populateNullableOptionsParser(ArgParser parser) =>
    parser..addFlag('nullable-option', defaultsTo: null);

final _$parserForNullableOptions = _$populateNullableOptionsParser(ArgParser());

NullableOptions parseNullableOptions(List<String> args) {
  final result = _$parserForNullableOptions.parse(args);
  return _$parseNullableOptionsResult(result);
}
