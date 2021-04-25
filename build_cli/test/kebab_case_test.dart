import 'package:build_cli/src/util.dart';
import 'package:test/test.dart';

const _items = {
  'simple': 'simple',
  'twoWords': 'two-words',
  'FirstBig': 'first-big'
};

void main() {
  for (var entry in _items.entries) {
    test(entry.key, () {
      expect(kebab(entry.key), entry.value);
    });
  }
}
