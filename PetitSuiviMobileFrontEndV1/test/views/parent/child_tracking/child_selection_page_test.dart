import 'package:flutter_test/flutter_test.dart';
import 'package:newv/views/parent/child_tracking/child_selection_page.dart';

void main() {
  group('resolveCurrentClassName', () {
    test('returns the newest class when backend sends newest first', () {
      final className = resolveCurrentClassName([
        {'name': 'Prescolaire B', 'year': '2025/2026'},
        {'name': 'Prescolaire A', 'year': '2024/2025'},
      ]);

      expect(className, 'Prescolaire B');
    });

    test('returns null when classes are missing', () {
      expect(resolveCurrentClassName(null), isNull);
      expect(resolveCurrentClassName(<Object?>[]), isNull);
    });

    test('returns null when the first entry is not a map', () {
      expect(resolveCurrentClassName(['Prescolaire B']), isNull);
    });
  });
}
