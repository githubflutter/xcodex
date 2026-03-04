import 'operator_engine.dart';
import 'table_hub.dart';

/// LINQ-style query extensions on [HubData].
///
/// All methods return a **new** map — the source is never mutated.
///
/// ```dart
/// final active = hub.current
///     .whereByC(1, '==', 'Active')
///     .orderByC(2)
///     .selectC([0, 1, 2]);
/// ```
extension WhereByC on HubData {
  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  /// Returns rows where column [colIndex] satisfies `[op] [value]`.
  ///
  /// Example: `data.whereByC(1, '==', 'Active')` keeps only rows whose C1
  /// equals `'Active'`.
  ///
  /// Throws [RangeError] if [colIndex] exceeds a row's length.
  HubData whereByC(int colIndex, String op, dynamic value) {
    return Map<dynamic, List<dynamic>>.fromEntries(
      entries.where((e) => OperatorEngine.evaluate(e.value[colIndex], op, value)),
    );
  }

  /// Returns rows matching **all** conditions (logical AND).
  ///
  /// Each condition is a three-element list: `[colIndex, op, value]`.
  ///
  /// ```dart
  /// data.whereAllByC([
  ///   [1, '==', 'Active'],
  ///   [2, '>', 100],
  /// ]);
  /// ```
  HubData whereAllByC(List<List<dynamic>> conditions) {
    return Map<dynamic, List<dynamic>>.fromEntries(
      entries.where(
        (e) => conditions.every(
          (c) => OperatorEngine.evaluate(e.value[c[0] as int], c[1] as String, c[2]),
        ),
      ),
    );
  }

  /// Returns rows matching **any** condition (logical OR).
  HubData whereAnyByC(List<List<dynamic>> conditions) {
    return Map<dynamic, List<dynamic>>.fromEntries(
      entries.where(
        (e) => conditions.any(
          (c) => OperatorEngine.evaluate(e.value[c[0] as int], c[1] as String, c[2]),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sorting
  // ---------------------------------------------------------------------------

  /// Returns rows sorted by column [colIndex].
  ///
  /// Values at [colIndex] must be [Comparable]. Set [desc] to `true` for
  /// descending order.
  HubData orderByC(int colIndex, {bool desc = false}) {
    final sorted = entries.toList()
      ..sort((a, b) {
        final cmp = (a.value[colIndex] as Comparable).compareTo(
          b.value[colIndex] as Comparable,
        );
        return desc ? -cmp : cmp;
      });
    return Map<dynamic, List<dynamic>>.fromEntries(sorted);
  }

  // ---------------------------------------------------------------------------
  // Projection
  // ---------------------------------------------------------------------------

  /// Returns a map containing only the specified column indices per row.
  ///
  /// The key (C0) is always preserved regardless of whether `0` is in
  /// [colIndices].
  HubData selectC(List<int> colIndices) {
    return map((key, row) {
      final projected = <dynamic>[
        for (final i in colIndices)
          if (i < row.length) row[i] else null,
      ];
      return MapEntry(key, projected);
    });
  }

  // ---------------------------------------------------------------------------
  // Aggregation helpers
  // ---------------------------------------------------------------------------

  /// Returns the distinct values found in column [colIndex].
  Set<dynamic> distinctC(int colIndex) {
    return values.map((row) => row[colIndex]).toSet();
  }

  /// Counts rows grouped by the value in column [colIndex].
  Map<dynamic, int> countByC(int colIndex) {
    final counts = <dynamic, int>{};
    for (final row in values) {
      final key = row[colIndex];
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }
}
