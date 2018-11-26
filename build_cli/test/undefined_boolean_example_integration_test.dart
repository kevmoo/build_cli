import 'package:test/test.dart';
import 'src/undefined_boolean_example.dart';

void main() {
  test('should be null', () {
    final options = parseNullableOptions([]);
    expect(options.nullableOption, equals(null));
  });
}
