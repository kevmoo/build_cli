import 'package:args/command_runner.dart';
import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';

import 'src/command_runner_example.dart';

void main() {
  test('use with CommandRunner', () async {
    final runner = CommandRunner<void>('my_app', '')
      ..addCommand(CommitCommand());
    await runner.run(['commit', '--all']);
    check(
      CommitCommand.debugOptionsWhenRun,
    ).isNotNull().has((o) => o.all, 'all').isTrue();
  });
}
