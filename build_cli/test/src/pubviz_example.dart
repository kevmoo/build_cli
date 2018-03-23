import 'package:args/args.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'pubviz_example.g.dart';

ArgParser get parser => _$parserForPeanutOptions;

@CliOptions()
class PeanutOptions {
}
