// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, unused_element

part of 'shared_helper_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(Map<T, String> enumValues, String source) =>
    enumValues.entries
        .singleWhere(
          (e) => e.value == source,
          orElse: () => throw ArgumentError(
            '`$source` is not one of the supported values: '
            '${enumValues.values.join(', ')}',
          ),
        )
        .key;

T? _$nullableEnumValueHelperNullable<T>(
  Map<T, String> enumValues,
  String? source,
) =>
    source == null ? null : _$enumValueHelper(enumValues, source);

T _$badNumberFormat<T extends num>(
  String source,
  String type,
  String argName,
) =>
    throw FormatException(
      'Cannot parse "$source" into `$type` for option "$argName".',
    );

FirstOptions _$parseFirstOptionsResult(ArgResults result) => FirstOptions()
  ..value = _$nullableEnumValueHelperNullable(
    _$OptionValueEnumMapBuildCli,
    result['value'] as String?,
  )
  ..count = int.tryParse(result['count'] as String) ??
      _$badNumberFormat(
        result['count'] as String,
        'int',
        'count',
      );

const _$OptionValueEnumMapBuildCli = <OptionValue, String>{
  OptionValue.a: 'a',
  OptionValue.b: 'b',
  OptionValue.c: 'c'
};

ArgParser _$populateFirstOptionsParser(ArgParser parser) => parser
  ..addOption(
    'value',
    allowed: ['a', 'b', 'c'],
  )
  ..addOption(
    'count',
  );

final _$parserForFirstOptions = _$populateFirstOptionsParser(ArgParser());

FirstOptions parseFirstOptions(List<String> args) {
  final result = _$parserForFirstOptions.parse(args);
  return _$parseFirstOptionsResult(result);
}

mixin _$FirstOptionsForCliCommand on CliCommand<FirstOptions> {
  @override
  void populateOptionsParser() => _$populateFirstOptionsParser(argParser);

  @override
  FirstOptions parseOptionsResult(ArgResults result) =>
      _$parseFirstOptionsResult(result);
}

SecondOptions _$parseSecondOptionsResult(ArgResults result) => SecondOptions()
  ..value = _$nullableEnumValueHelperNullable(
    _$OptionValueEnumMapBuildCli,
    result['value'] as String?,
  )
  ..count = int.tryParse(result['count'] as String) ??
      _$badNumberFormat(
        result['count'] as String,
        'int',
        'count',
      );

ArgParser _$populateSecondOptionsParser(ArgParser parser) => parser
  ..addOption(
    'value',
    allowed: ['a', 'b', 'c'],
  )
  ..addOption(
    'count',
  );

final _$parserForSecondOptions = _$populateSecondOptionsParser(ArgParser());

SecondOptions parseSecondOptions(List<String> args) {
  final result = _$parserForSecondOptions.parse(args);
  return _$parseSecondOptionsResult(result);
}

mixin _$SecondOptionsForCliCommand on CliCommand<SecondOptions> {
  @override
  void populateOptionsParser() => _$populateSecondOptionsParser(argParser);

  @override
  SecondOptions parseOptionsResult(ArgResults result) =>
      _$parseSecondOptionsResult(result);
}
