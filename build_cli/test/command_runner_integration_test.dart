import 'package:args/command_runner.dart';
import 'package:test/test.dart';

import 'src/command_runner_example.dart';

void main() {
  test('use with CommandRunner', () async {
    final runner = CommandRunner('my_app', '')..addCommand(CommitCommand());
    await runner.run(['commit', '--all']);
    expect(CommitCommand.debugOptionsWhenRun?.all, isTrue);
  });
}
