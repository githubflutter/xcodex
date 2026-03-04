/// Maps human-readable keys (e.g., "Email") to positional indices (e.g., "C4").
class SchemaMapper {
  final Map<String, int> _keyToIndex;

  SchemaMapper._(this._keyToIndex);

  /// Creates a [SchemaMapper] from a dynamic JSON schema.
  /// Handles both numeric indices and "C1" style string indices.
  ///
  /// Example input schema:
  /// {
  ///   "Id": "C0",
  ///   "Name": "C1",
  ///   "Email": "C2",
  ///   "Status": 3
  /// }
  factory SchemaMapper.fromJsonSchema(Map<String, dynamic> schema) {
    final Map<String, int> mapping = {};
    schema.forEach((key, value) {
      if (value is int) {
        mapping[key] = value;
      } else if (value is String) {
        if (value.toUpperCase().startsWith('C')) {
          final index = int.tryParse(value.substring(1));
          if (index != null) {
            mapping[key] = index;
          }
        } else {
          final indexVal = int.tryParse(value);
          if (indexVal != null) {
            mapping[key] = indexVal;
          }
        }
      }
    });
    return SchemaMapper._(mapping);
  }

  /// Get the positional index for a given field key. Returns null if not found.
  int? getIndex(String key) => _keyToIndex[key];

  /// Get the full unmodifiable map of keys to indices.
  Map<String, int> get mapping => Map.unmodifiable(_keyToIndex);
}
