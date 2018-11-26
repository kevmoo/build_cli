import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'undefined_boolean_example.g.dart';

@CliOptions()
class NullableOptions {
  @CliOption(
    nullable: true,
    defaultsTo: null,
  )
  final bool nullableOption;

  NullableOptions(this.nullableOption);
}
