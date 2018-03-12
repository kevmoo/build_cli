import 'package:test/test.dart';

import 'src/example.dart';

void main() {
  test('no args', () {
    var options = parsePeanutOptions([]);

    expect(options.directory, 'web');
    expect(options.branch, 'gh-pages');
    expect(options.mode, PubBuildMode.release);
    expect(options.buildConfig, isNull);
    expect(options.message, 'Built <directory>');
    expect(options.buildTool, isNull);
    expect(options.help, isFalse);
  });

  test('usage', () {
    expect(parser.usage, r'''-d, --directory       (defaults to "web")
-b, --branch          (defaults to "gh-pages")
    --mode            The mode to run `pub build` in.
                      [release (default), debug]

-c, --build-config    The configuration to use when running `build_runner`. If this option is not set, `release` is used if `build.release.yaml` exists in the current directory.
-m, --message         (defaults to "Built <directory>")
-t, --build-tool      If `build.release.yaml` exists in the current directory, defaults to "build". Otherwise, "pub".
                      [pub, build]

-h, --help            Prints usage information.''');
  });
}
