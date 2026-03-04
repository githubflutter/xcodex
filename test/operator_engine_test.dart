import 'package:test/test.dart';
import 'package:xcodex/xcodex.dart';

void main() {
  group('OperatorEngine', () {
    // ── Equality ──────────────────────────────────────────────────────────
    test('== returns true for equal values', () {
      expect(OperatorEngine.evaluate(42, '==', 42), isTrue);
      expect(OperatorEngine.evaluate('abc', '==', 'abc'), isTrue);
    });

    test('== returns false for unequal values', () {
      expect(OperatorEngine.evaluate(42, '==', 99), isFalse);
    });

    test('!= returns true for unequal values', () {
      expect(OperatorEngine.evaluate(1, '!=', 2), isTrue);
    });

    test('!= returns false for equal values', () {
      expect(OperatorEngine.evaluate('x', '!=', 'x'), isFalse);
    });

    // ── Relational ────────────────────────────────────────────────────────
    test('> with ints', () {
      expect(OperatorEngine.evaluate(10, '>', 5), isTrue);
      expect(OperatorEngine.evaluate(5, '>', 10), isFalse);
    });

    test('< with doubles', () {
      expect(OperatorEngine.evaluate(1.5, '<', 2.5), isTrue);
      expect(OperatorEngine.evaluate(2.5, '<', 1.5), isFalse);
    });

    test('>= boundary', () {
      expect(OperatorEngine.evaluate(5, '>=', 5), isTrue);
      expect(OperatorEngine.evaluate(4, '>=', 5), isFalse);
    });

    test('<= boundary', () {
      expect(OperatorEngine.evaluate(5, '<=', 5), isTrue);
      expect(OperatorEngine.evaluate(6, '<=', 5), isFalse);
    });

    test('> with strings (lexicographic)', () {
      expect(OperatorEngine.evaluate('b', '>', 'a'), isTrue);
      expect(OperatorEngine.evaluate('a', '>', 'b'), isFalse);
    });

    // ── String operators ──────────────────────────────────────────────────
    test('contains', () {
      expect(
        OperatorEngine.evaluate('hello world', 'contains', 'world'),
        isTrue,
      );
      expect(OperatorEngine.evaluate('hello', 'contains', 'xyz'), isFalse);
    });

    test('startsWith', () {
      expect(OperatorEngine.evaluate('flutter', 'startsWith', 'flu'), isTrue);
      expect(OperatorEngine.evaluate('flutter', 'startsWith', 'xyz'), isFalse);
    });

    test('endsWith', () {
      expect(OperatorEngine.evaluate('dart', 'endsWith', 'rt'), isTrue);
      expect(OperatorEngine.evaluate('dart', 'endsWith', 'xx'), isFalse);
    });

    // ── Error ─────────────────────────────────────────────────────────────
    test('unknown operator throws ArgumentError', () {
      expect(
        () => OperatorEngine.evaluate(1, 'LIKE', 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    // ── Edge cases ────────────────────────────────────────────────────────
    test('null equality', () {
      expect(OperatorEngine.evaluate(null, '==', null), isTrue);
      expect(OperatorEngine.evaluate(null, '!=', 42), isTrue);
    });

    test('contains coerces non-strings via toString()', () {
      expect(OperatorEngine.evaluate(12345, 'contains', '234'), isTrue);
    });
  });
}
