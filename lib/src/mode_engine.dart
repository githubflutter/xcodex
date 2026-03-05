import 'table_hub.dart';

/// Built-in view modes for shaping [HubData] snapshots.
enum HubMode {
  /// Returns full rows unchanged.
  full,

  /// Returns only the first N columns (always including C0).
  thin,

  /// Returns only selected columns (always including C0).
  mini,

  /// Returns user-defined row shape/filter via callbacks.
  custom,
}

/// Transforms a row in [HubMode.custom].
typedef HubRowTransformer =
    List<dynamic> Function(List<dynamic> row, dynamic key);

/// Optional row filter callback for mode operations.
typedef HubRowPredicate = bool Function(List<dynamic> row, dynamic key);

/// Mode helpers for [HubData].
extension HubModeExtension on HubData {
  /// Applies a mode to the current map and returns a new transformed map.
  ///
  /// - [miniColumns] is required for [HubMode.mini].
  /// - [transform] is required for [HubMode.custom].
  /// - [thinColumns] must be >= 1 for [HubMode.thin].
  HubData applyMode(
    HubMode mode, {
    List<int>? miniColumns,
    int thinColumns = 2,
    HubRowTransformer? transform,
    HubRowPredicate? where,
  }) {
    final source = where == null
        ? entries
        : entries.where((e) => where(e.value, e.key));

    return switch (mode) {
      HubMode.full => Map<dynamic, List<dynamic>>.fromEntries(
        source.map((e) => MapEntry(e.key, List<dynamic>.from(e.value))),
      ),
      HubMode.thin => _thin(source, thinColumns),
      HubMode.mini => _mini(source, miniColumns),
      HubMode.custom => _custom(source, transform),
    };
  }

  /// Returns full rows unchanged.
  HubData fullMode({HubRowPredicate? where}) {
    return applyMode(HubMode.full, where: where);
  }

  /// Returns only the first [columns] columns, always keeping C0.
  HubData thinMode({int columns = 2, HubRowPredicate? where}) {
    return applyMode(HubMode.thin, thinColumns: columns, where: where);
  }

  /// Returns only selected [columns], always keeping C0.
  HubData miniMode(List<int> columns, {HubRowPredicate? where}) {
    return applyMode(HubMode.mini, miniColumns: columns, where: where);
  }

  /// Applies user-defined transform and optional filter.
  HubData customMode({
    required HubRowTransformer transform,
    HubRowPredicate? where,
  }) {
    return applyMode(HubMode.custom, transform: transform, where: where);
  }

  HubData _thin(
    Iterable<MapEntry<dynamic, List<dynamic>>> source,
    int thinColumns,
  ) {
    if (thinColumns < 1) {
      throw ArgumentError.value(
        thinColumns,
        'thinColumns',
        'thinColumns must be >= 1.',
      );
    }

    final indices = <int>[for (var i = 0; i < thinColumns; i++) i];
    return Map<dynamic, List<dynamic>>.fromEntries(
      source.map((e) => MapEntry(e.key, _projectRow(e.value, indices))),
    );
  }

  HubData _mini(
    Iterable<MapEntry<dynamic, List<dynamic>>> source,
    List<int>? miniColumns,
  ) {
    if (miniColumns == null || miniColumns.isEmpty) {
      throw ArgumentError('miniColumns must be provided for HubMode.mini.');
    }

    final indices = <int>{0, ...miniColumns}.toList()..sort();
    return Map<dynamic, List<dynamic>>.fromEntries(
      source.map((e) => MapEntry(e.key, _projectRow(e.value, indices))),
    );
  }

  HubData _custom(
    Iterable<MapEntry<dynamic, List<dynamic>>> source,
    HubRowTransformer? transform,
  ) {
    if (transform == null) {
      throw ArgumentError('transform must be provided for HubMode.custom.');
    }

    return Map<dynamic, List<dynamic>>.fromEntries(
      source.map((e) {
        var row = List<dynamic>.from(transform(e.value, e.key));
        if (row.isEmpty) {
          row = [e.key];
        } else if (row[0] != e.key) {
          row = [e.key, ...row.skip(1)];
        }
        return MapEntry(e.key, row);
      }),
    );
  }

  List<dynamic> _projectRow(List<dynamic> row, List<int> indices) {
    return [
      for (final index in indices)
        if (index < row.length) row[index] else null,
    ];
  }
}
