// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, require_trailing_commas

part of 'nullable_defaults_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$badNumberFormat<T extends num>(
  String source,
  String type,
  String argName,
) => throw FormatException(
  'Cannot parse "$source" into `$type` for option "$argName".',
);

NullableOptions _$parseNullableOptionsResult(ArgResults result) =>
    NullableOptions(
      result['nullable-boolean'] as bool?,
      result['nullable-integer'] != null
          ? int.tryParse(result['nullable-integer'] as String) ??
                _$badNumberFormat(
                  result['nullable-integer'] as String,
                  'int',
                  'nullable-integer',
                )
          : null,
      result['nullable-double'] != null
          ? double.tryParse(result['nullable-double'] as String) ??
                _$badNumberFormat(
                  result['nullable-double'] as String,
                  'double',
                  'nullable-double',
                )
          : null,
      result['nullable-num'] != null
          ? num.tryParse(result['nullable-num'] as String) ??
                _$badNumberFormat(
                  result['nullable-num'] as String,
                  'num',
                  'nullable-num',
                )
          : null,
    );

ArgParser _$populateNullableOptionsParser(ArgParser parser) => parser
  ..addFlag('nullable-boolean', defaultsTo: null)
  ..addOption('nullable-integer')
  ..addOption('nullable-double')
  ..addOption('nullable-num');

final _$parserForNullableOptions = _$populateNullableOptionsParser(ArgParser());

NullableOptions parseNullableOptions(List<String> args) {
  final result = _$parserForNullableOptions.parse(args);
  return _$parseNullableOptionsResult(result);
}
