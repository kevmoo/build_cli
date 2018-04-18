import 'package:build_cli_annotations/build_cli_annotations.dart';

@CliOptions()
class Empty {}

@CliOptions()
const theAnswer = 42;

@CliOptions()
void annotatedMethod() => null;

@CliOptions()
class UnknownCtorParamType {
  int number;

  // ignore: undefined_class, field_initializer_not_assignable
  UnknownCtorParamType(Bob number) : this.number = number;
}

@CliOptions()
class UnknownFieldType {
  // ignore: undefined_class
  Bob number;
}
