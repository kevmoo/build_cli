import 'package:args/command_runner.dart';
import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'command_runner_example.g.dart';

@CliOptions()
class CommitCommandOptions {
  @CliOption(abbr: 'a')
  final bool all;

  CommitCommandOptions({
    required this.all,
  });
}

class CommitCommand extends CliCommand<CommitCommandOptions>
  with _$CommitCommandOptionsForCliCommand {
  static CommitCommandOptions? debugOptionsWhenRun; // for testing purpose

  @override
  final name = 'commit';
  @override
  final description = 'Record changes to the repository.';

  @override
  void run() {
    debugOptionsWhenRun = cliArgResults; // for testing purpose
  }
}
