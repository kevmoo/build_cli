import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'nullable_defaults_example.g.dart';

@CliOptions()
class NullableOptions {
  @CliOption(defaultsTo: null)
  final bool? nullableBoolean;

  @CliOption(defaultsTo: null)
  final int? nullableInteger;

  @CliOption(defaultsTo: null)
  final double? nullableDouble;

  @CliOption(defaultsTo: null)
  final num? nullableNum;

  NullableOptions(
    this.nullableBoolean,
    this.nullableInteger,
    this.nullableDouble,
    this.nullableNum,
  );
}
