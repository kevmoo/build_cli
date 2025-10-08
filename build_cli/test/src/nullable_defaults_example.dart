import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'nullable_defaults_example.g.dart';

@CliOptions()
class NullableOptions {
  @CliOption()
  final bool? nullableBoolean;

  @CliOption()
  final int? nullableInteger;

  @CliOption()
  final double? nullableDouble;

  @CliOption()
  final num? nullableNum;

  NullableOptions(
    this.nullableBoolean,
    this.nullableInteger,
    this.nullableDouble,
    this.nullableNum,
  );
}
