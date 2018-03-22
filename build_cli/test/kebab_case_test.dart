import 'package:test/test.dart';

import 'package:build_cli/src/util.dart';

final _items = const {
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
