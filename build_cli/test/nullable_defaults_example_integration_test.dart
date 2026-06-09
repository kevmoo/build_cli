import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'src/nullable_defaults_example.dart';

void main() {
  test('should be null', () {
    final options = parseNullableOptions([]);
    check(options.nullableBoolean).isNull();
    check(options.nullableInteger).isNull();
    check(options.nullableDouble).isNull();
    check(options.nullableNum).isNull();
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
    check(options.nullableBoolean).equals(true);
    check(options.nullableInteger).equals(10);
    check(options.nullableDouble).equals(1.1);
    check(options.nullableNum).equals(3.4);
  });
}
