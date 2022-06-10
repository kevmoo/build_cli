import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'command_runner_example.g.dart';

@CliOptions()
class CommitOptions {
  @CliOption(abbr: 'a')
  final bool all;

  CommitOptions({
    required this.all,
  });
}

class CommitCommand extends _$CommitOptionsCommand<void> {
  static CommitOptions? debugOptionsWhenRun; // for testing purpose

  @override
  final name = 'commit';
  @override
  final description = 'Record changes to the repository.';

  @override
  void run() {
    debugOptionsWhenRun = _options; // for testing purpose
  }
}
