import 'package:test/test.dart';

import 'src/pubviz_example.dart';

void main() {
  test('no args', () {
    var options = parsePeanutOptions([]);

    expect(options.secret, isNull);
    expect(options.ignorePackages, []);
    expect(options.productionPort, 8080);
  });

  group('with invalid args', () {
    var items = {
      'Could not find an option named "help".': ['--no-help'],
      '"foo" is not an allowed value for option "format".': ['--format', 'foo'],
      // TODO: pass a string in for production port!
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
    expect(parser.usage, r'''
-f, --format             
          [dot]          Generate a GraphViz 'dot' file.
          [html]         Wrap the GraphViz dot format in an HTML template which renders it.

-i, --ignore-packages    A comma seperated list of packages to exclude in the output.
    --production-port    (defaults to "8080")''');
  });
}
