import 'package:test/test.dart';
import 'package:xcodex/xcodex.dart';

void main() {
  // Sample data: C0=id, C1=status, C2=amount, C3=name
  final HubData sampleData = {
    'a': ['a', 'Active', 150, 'Alice'],
    'b': ['b', 'Inactive', 200, 'Bob'],
    'c': ['c', 'Active', 80, 'Charlie'],
    'd': ['d', 'Pending', 300, 'Dave'],
  };

  group('whereByC', () {
    test('filters rows by equality on C1', () {
      final result = sampleData.whereByC(1, '==', 'Active');
      expect(result.keys, unorderedEquals(['a', 'c']));
    });

    test('filters rows by > on C2', () {
      final result = sampleData.whereByC(2, '>', 100);
      expect(result.keys, unorderedEquals(['a', 'b', 'd']));
    });

    test('filters rows by contains on C3', () {
      final result = sampleData.whereByC(3, 'contains', 'li');
      expect(result.keys, unorderedEquals(['a', 'c']));
    });

    test('returns empty map when no match', () {
      final result = sampleData.whereByC(1, '==', 'Cancelled');
      expect(result, isEmpty);
    });
  });

  group('whereAllByC', () {
    test('AND: Active AND amount > 100', () {
      final result = sampleData.whereAllByC([
        [1, '==', 'Active'],
        [2, '>', 100],
      ]);
      expect(result.keys, equals(['a']));
    });
  });

  group('whereAnyByC', () {
    test('OR: Active OR amount >= 300', () {
      final result = sampleData.whereAnyByC([
        [1, '==', 'Active'],
        [2, '>=', 300],
      ]);
      expect(result.keys, unorderedEquals(['a', 'c', 'd']));
    });
  });

  group('orderByC', () {
    test('sorts ascending by C2', () {
      final result = sampleData.orderByC(2);
      expect(result.keys.toList(), equals(['c', 'a', 'b', 'd']));
    });

    test('sorts descending by C2', () {
      final result = sampleData.orderByC(2, desc: true);
      expect(result.keys.toList(), equals(['d', 'b', 'a', 'c']));
    });

    test('sorts by C3 (string, lexicographic)', () {
      final result = sampleData.orderByC(3);
      expect(result.keys.toList(), equals(['a', 'b', 'c', 'd']));
    });
  });

  group('selectC', () {
    test('projects specific columns', () {
      final result = sampleData.selectC([0, 2]);
      expect(result['a'], equals(['a', 150]));
      expect(result['b'], equals(['b', 200]));
    });

    test('handles out-of-range index gracefully', () {
      final result = sampleData.selectC([0, 99]);
      expect(result['a'], equals(['a', null]));
    });
  });

  group('distinctC', () {
    test('returns unique C1 values', () {
      final result = sampleData.distinctC(1);
      expect(result, unorderedEquals({'Active', 'Inactive', 'Pending'}));
    });
  });

  group('countByC', () {
    test('counts rows by C1', () {
      final result = sampleData.countByC(1);
      expect(result, {'Active': 2, 'Inactive': 1, 'Pending': 1});
    });
  });

  group('chaining', () {
    test('whereByC → orderByC → selectC', () {
      final result = sampleData
          .whereByC(1, '==', 'Active')
          .orderByC(2, desc: true)
          .selectC([0, 2]);

      expect(result.keys.toList(), equals(['a', 'c']));
      expect(result['a'], equals(['a', 150]));
      expect(result['c'], equals(['c', 80]));
    });
  });
}
