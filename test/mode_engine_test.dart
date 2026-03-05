import 'package:test/test.dart';
import 'package:xcodex/xcodex.dart';

void main() {
  final HubData sample = {
    'u1': ['u1', 'Alice', 'Active', 150],
    'u2': ['u2', 'Bob', 'Inactive', 90],
    'u3': ['u3', 'Carla', 'Active', 210],
  };

  group('HubModeExtension', () {
    test('fullMode returns full rows', () {
      final result = sample.fullMode();
      expect(result['u1'], equals(['u1', 'Alice', 'Active', 150]));
      expect(result['u2'], equals(['u2', 'Bob', 'Inactive', 90]));
    });

    test('thinMode keeps first N columns', () {
      final result = sample.thinMode(columns: 2);
      expect(result['u1'], equals(['u1', 'Alice']));
      expect(result['u3'], equals(['u3', 'Carla']));
    });

    test('thinMode throws when columns < 1', () {
      expect(() => sample.thinMode(columns: 0), throwsA(isA<ArgumentError>()));
    });

    test('miniMode keeps selected columns and always includes C0', () {
      final result = sample.miniMode([2, 3]);
      expect(result['u1'], equals(['u1', 'Active', 150]));
      expect(result['u2'], equals(['u2', 'Inactive', 90]));
    });

    test('miniMode fills null for out-of-range indices', () {
      final result = sample.miniMode([3, 99]);
      expect(result['u1'], equals(['u1', 150, null]));
    });

    test('miniMode throws when columns are empty', () {
      expect(() => sample.miniMode([]), throwsA(isA<ArgumentError>()));
    });

    test('customMode applies transform and preserves C0', () {
      final result = sample.customMode(
        transform: (row, key) => [key, row[1], (row[3] as int) * 2],
      );

      expect(result['u1'], equals(['u1', 'Alice', 300]));
      expect(result['u3'], equals(['u3', 'Carla', 420]));
    });

    test('customMode can filter rows using where', () {
      final result = sample.customMode(
        where: (row, _) => row[2] == 'Active',
        transform: (row, key) => [key, row[1]],
      );

      expect(result.keys, unorderedEquals(['u1', 'u3']));
      expect(result['u1'], equals(['u1', 'Alice']));
    });

    test('customMode throws when transform is missing via applyMode', () {
      expect(
        () => sample.applyMode(HubMode.custom),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('applyMode supports explicit HubMode.mini', () {
      final result = sample.applyMode(HubMode.mini, miniColumns: [1, 2]);
      expect(result['u2'], equals(['u2', 'Bob', 'Inactive']));
    });
  });
}
