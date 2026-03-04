import 'table_hub.dart';

/// A concrete implementation of TableHub to be used within the GlobalDataSet.
class _GenericTableHub extends TableHub {
  _GenericTableHub();
}

/// A centralized singleton hub that manages multiple TableHub instances.
class GlobalDataSet {
  static final GlobalDataSet _instance = GlobalDataSet._internal();

  /// Gets the singleton instance of GlobalDataSet.
  factory GlobalDataSet() => _instance;

  GlobalDataSet._internal();

  final Map<String, TableHub> _tables = {};

  /// Retrieves a [TableHub] by its [tableName].
  /// If the table does not exist, it will track a new one.
  TableHub table(String tableName) {
    return _tables.putIfAbsent(tableName, () => _GenericTableHub());
  }

  /// Clears and disposes all tables in the dataset.
  void disposeAll() {
    for (var hub in _tables.values) {
      hub.dispose();
    }
    _tables.clear();
  }
}
