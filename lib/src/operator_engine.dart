/// Evaluates string-based comparison operators against dynamic values.
///
/// Designed to process operator tokens sourced from JSON filter definitions,
/// enabling runtime query construction without compile-time types.
abstract final class OperatorEngine {
  /// Supported operator tokens.
  static const Set<String> supportedOps = {
    '==',
    '!=',
    '>',
    '<',
    '>=',
    '<=',
    'contains',
    'startsWith',
    'endsWith',
  };

  /// Evaluates [left] [op] [right] and returns the boolean result.
  ///
  /// For relational operators (`>`, `<`, `>=`, `<=`) both operands must be
  /// [Comparable]. String operators (`contains`, `startsWith`, `endsWith`)
  /// coerce both sides via `.toString()`.
  ///
  /// Throws [ArgumentError] if [op] is not in [supportedOps].
  static bool evaluate(dynamic left, String op, dynamic right) {
    return switch (op) {
      '==' => left == right,
      '!=' => left != right,
      '>' => _compare(left, right) > 0,
      '<' => _compare(left, right) < 0,
      '>=' => _compare(left, right) >= 0,
      '<=' => _compare(left, right) <= 0,
      'contains' => left.toString().contains(right.toString()),
      'startsWith' => left.toString().startsWith(right.toString()),
      'endsWith' => left.toString().endsWith(right.toString()),
      _ => throw ArgumentError.value(op, 'op', 'Unsupported operator'),
    };
  }

  /// Compares two [Comparable] values.
  ///
  /// Throws [TypeError] if either operand is not [Comparable].
  static int _compare(dynamic a, dynamic b) {
    return (a as Comparable).compareTo(b as Comparable);
  }
}
