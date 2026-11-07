import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/core/data/uzbekistan_regions.dart';

void main() {
  test('regions are listed alphabetically', () {
    final names = sortedAlphabetically([
      for (final r in uzbekistanRegions) r.name,
    ]);
    expect(names.first, 'Andijon viloyati');
    expect(names.last, 'Xorazm viloyati');
    expect(
      names.indexOf('Toshkent shahri'),
      lessThan(names.indexOf('Toshkent viloyati')),
    );
    expect([...names]..sort(), isNot(isEmpty));
  });

  test('apostrophes are ignored when sorting', () {
    expect(
      sortedAlphabetically([
        "Chinoz",
        "Bo'ka",
        "Bekobod",
        "Oqqo'rg'on",
        "Ohangaron",
      ]),
      ["Bekobod", "Bo'ka", "Chinoz", "Ohangaron", "Oqqo'rg'on"],
    );
  });

  test('every district list is alphabetical and keeps all districts', () {
    for (final region in uzbekistanRegions) {
      final original = [for (final d in region.districts) d.name];
      final sorted = sortedAlphabetically(original);
      expect(sorted.length, original.length);
      expect({...sorted}, {...original});
    }
  });
}
