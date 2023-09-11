import 'package:test/test.dart';
import 'src/nullable_defaults_example.dart';

void main() {
  test('should be null', () {
    final options = parseNullableOptions([]);
    expect(options.nullableBoolean, equals(null));
    expect(options.nullableInteger, equals(null));
    expect(options.nullableDouble, equals(null));
    expect(options.nullableNum, equals(null));
  });

  test('should be value from arguments', () {
    final options = parseNullableOptions([
      '--nullable-boolean',
      'true',
      '--nullable-integer',
      '10',
      '--nullable-double',
      '1.1',
      '--nullable-num',
      '3.4',
    ]);
    expect(options.nullableBoolean, equals(true));
    expect(options.nullableInteger, equals(10));
    expect(options.nullableDouble, equals(1.1));
    expect(options.nullableNum, equals(3.4));
  });
}
