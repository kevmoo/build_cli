import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';

import 'src/peanut_example.dart';

void main() {
  test('no args', () {
    final options = parsePeanutOptions([]);

    check(options.directory).equals('web');
    check(options.branch).equals('gh-pages');
    check(options.mode).equals(PubBuildMode.release);
    check(options.modeWasParsed).isFalse();
    check(options.buildConfig).isNull();
    check(options.buildConfigWasParsed).isFalse();
    check(options.message).equals('Built <directory>');
    check(options.buildTool).isNull();
    check(options.debugBuildTool).equals(BuildTool.$loco);
    check(options.help).isFalse();
    check(options.release).isTrue();
    check(options.maxRuntime).isNull();
    check(options.rest).isEmpty();
  });

  test('some args', () {
    final options = parsePeanutOptions([
      '-d',
      'dir',
      '--no-release',
      '--mode',
      'debug',
      '--bazel-options',
      'to-source',
      '-h',
      '--max-runtime',
      '42',
      '--debug-build-tool',
      'pub',
      'extra',
      'things',
    ]);

    check(options.directory).equals('dir');
    check(options.branch).equals('gh-pages');
    check(options.mode).equals(PubBuildMode.debug);
    check(options.modeWasParsed).isTrue();
    check(options.buildConfig).isNull();
    check(options.buildConfigWasParsed).isFalse();
    check(options.bazelOptions).equals(BazelOptions.toSource);
    check(options.message).equals('Built <directory>');
    check(options.buildTool).isNull();
    check(options.debugBuildTool).equals(BuildTool.pub);
    check(options.help).isTrue();
    check(options.release).isFalse();
    check(options.maxRuntime).equals(const Duration(seconds: 42));
    check(options.rest).deepEquals(['extra', 'things']);
  });

  group('with invalid args', () {
    final items = {
      'Cannot negate option "--no-help".': ['--no-help'],
      '"foo" is not an allowed value for option "--mode".': ['--mode', 'foo'],
      'The value provided for "max-runtime" – "bob" – was not a number.': [
        '--max-runtime',
        'bob',
      ],
    };

    for (var item in items.entries) {
      test('`${item.value.join(' ')}`', () {
        check(() => parsePeanutOptions(item.value))
            .throws<FormatException>()
            .has((e) => e.message, 'message')
            .equals(item.key);
      });
    }
  });

  test('usage', () {
    final prettyUsage = prettyParser.usage;
    printOnFailure(prettyUsage);
    check(prettyUsage).equals(r'''
-d, --directory           (defaults to "web")
-b, --branch              (defaults to "gh-pages")
    --mode                The mode to run `pub build` in.
                          [release (default), debug]
-c, --build-config        The configuration to use when running `build_runner`.
                          If this option is not set, `release` is used if
                          `build.release.yaml` exists in the current directory.
-m, --message             (defaults to "Built <directory>")
-t, --build-tool          If `build.release.yaml` exists in the current
                          directory, defaults to "build". Otherwise, "pub".
                          [pub, build, $loco]
    --debug-build-tool    The build tool to use for debugging.
                          [pub, build, $loco (default)]
    --bazel-options       nice options
                          [to-source (default), from-source, via-assets]
-h, --help                Prints usage information. Which is so "$" you don't
                          even know it!
    --[no-]release        (defaults to on)
    --max-runtime         
    --min-runtime         (defaults to "0")''');
  });
}
