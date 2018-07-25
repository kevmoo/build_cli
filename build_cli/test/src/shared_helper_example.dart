import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'shared_helper_example.g.dart';

enum OptionValue { a, b, c }

@CliOptions()
class FirstOptions {
  OptionValue value;
  int count;
}

@CliOptions()
class SecondOptions {
  OptionValue value;
  int count;
}
