import 'dart:io';

import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('readme contents', () {
    final readmeContent = File('README.md').readAsStringSync();

    final exampleContent = File('example/example.dart')
        .readAsLinesSync()
        .skipWhile(
          (line) => !line.startsWith("import 'package:build_cli_annotations"),
        )
        .where((line) => !line.trim().startsWith('///'))
        .takeWhile((line) => !line.startsWith('void main'))
        .join('\n')
        .trim();

    printOnFailure(exampleContent);

    check(readmeContent).contains(exampleContent);
  });
}
