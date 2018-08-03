import 'package:test/test.dart';

import 'src/pubviz_example.dart';

void main() {
  test('no args', () {
    var options = parsePubvizOptions([]);

    expect(options.secret, isNull);
    expect(options.ignorePackages, []);
    expect(options.productionPort, 8080);
    expect(options.numValue, 3.14);
    expect(options.doubleValue, 3000.0);
    expect(options.devPort, 8080);
  });

  group('with invalid args', () {
    var items = {
      'Could not find an option named "help".': ['--no-help'],
      '"foo" is not an allowed value for option "format".': ['--format', 'foo'],
      'Cannot parse "3.14" into `int` for option "production-port".': [
        '--production-port',
        '3.14'
      ],
      'Cannot parse "foo" into `int` for option "production-port".': [
        '--production-port',
        'foo'
      ],
      'Cannot parse "foo" into `num` for option "num-value".': [
        '--num-value',
        'foo'
      ],
      'Cannot parse "foo" into `double` for option "double-value".': [
        '--double-value',
        'foo'
      ],
    };

    for (var item in items.entries) {
      test('`${item.value.join(' ')}`', () {
        expect(() => parsePubvizOptions(item.value), throwsA((error) {
          expect(error, isFormatException);
          expect((error as FormatException).message, item.key);
          return true;
        }));
      });
    }
  });

  test('usage', () {
    var prettyUsage = prettyParser.usage;
    printOnFailure(prettyUsage);
    expect(prettyUsage, r'''
-f, --format                    
          [dot]                 Generate a GraphViz 'dot' file.
          [html] (default)      Wrap the GraphViz dot format in an HTML template
                                which renders it.

-i, --ignore-packages           A comma seperated list of packages to exclude in
                                the output.

    --production-port=<PORT>    (defaults to "8080")
    --num-value                 (defaults to "3.14")
    --double-value              (defaults to "3000.0")
    --dev-port                  
          [42]                  the knowledge port
          [8080] (default)      the cool port
          [9090]                the alt port

    --list-of-nothing           
    --list-of-dynamic           
    --list-of-object            ''');
  });
}
