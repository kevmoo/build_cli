import 'package:test/test.dart';

import 'src/peanut_example.dart';

void main() {
  test('no args', () {
    var options = parsePeanutOptions([]);

    expect(options.directory, 'web');
    expect(options.branch, 'gh-pages');
    expect(options.mode, PubBuildMode.release);
    expect(options.modeWasParsed, isFalse);
    expect(options.buildConfig, isNull);
    expect(options.buildConfigWasParsed, isFalse);
    expect(options.message, 'Built <directory>');
    expect(options.buildTool, isNull);
    expect(options.help, isFalse);
    expect(options.rest, isEmpty);
  });

  test('some args', () {
    var options = parsePeanutOptions(
        ['-d', 'dir', '--mode', 'debug', '-h', 'extra', 'things']);

    expect(options.directory, 'dir');
    expect(options.branch, 'gh-pages');
    expect(options.mode, PubBuildMode.debug);
    expect(options.modeWasParsed, isTrue);
    expect(options.buildConfig, isNull);
    expect(options.buildConfigWasParsed, isFalse);
    expect(options.message, 'Built <directory>');
    expect(options.buildTool, isNull);
    expect(options.help, isTrue);
    expect(options.rest, ['extra', 'things']);
  });

  group('with invalid args', () {
    var items = {
      'Cannot negate option "help".': ['--no-help'],
      '"foo" is not an allowed value for option "mode".': ['--mode', 'foo']
    };

    for (var item in items.entries) {
      test('`${item.value.join(' ')}`', () {
        expect(() => parsePeanutOptions(item.value), throwsA((error) {
          expect(error, isFormatException);
          expect((error as FormatException).message, item.key);
          return true;
        }));
      });
    }
  });

  test('usage', () {
    expect(parser.usage, r'''-d, --directory        (defaults to "web")
-b, --branch           (defaults to "gh-pages")
    --mode             The mode to run `pub build` in.
                       [release (default), debug]

-c, --build-config     The configuration to use when running `build_runner`. If this option is not set, `release` is used if `build.release.yaml` exists in the current directory.
-m, --message          (defaults to "Built <directory>")
-t, --build-tool       If `build.release.yaml` exists in the current directory, defaults to "build". Otherwise, "pub".
                       [pub, build]

    --bazel-options    [to-source, from-source, via-assets]
-h, --help             Prints usage information.''');
  });
}
