import 'schema_mapper.dart';

/// Utility that converts a raw JSON Map into a positional List<dynamic>
/// suitable for TableHub (C0...Cn).
class JsonFlattener {
  /// Flattens a [json] map into a positional list based on a [mapper].
  /// Missing fields from the JSON will be inserted as null.
  static List<dynamic> flatten(Map<String, dynamic> json, SchemaMapper mapper) {
    if (mapper.mapping.isEmpty) return [];

    // Find the maximum index to determine the required list length.
    int maxIndex = -1;
    for (final index in mapper.mapping.values) {
      if (index > maxIndex) {
        maxIndex = index;
      }
    }

    if (maxIndex == -1) return [];

    // Initialize list with nulls up to maxIndex.
    final List<dynamic> flattened = List<dynamic>.filled(maxIndex + 1, null);

    // Populate the list from JSON using the schema mapper.
    for (final entry in json.entries) {
      final index = mapper.getIndex(entry.key);
      if (index != null) {
        flattened[index] = entry.value;
      }
    }

    // TableHub requires row[0] == id. If C0 is null, upsert will fail assertion.
    assert(
      flattened.isNotEmpty && flattened[0] != null,
      'C0 (Id) must not be null for TableHub compatibility.',
    );

    return flattened;
  }

  /// Helper to convert a list of JSON maps into a list of positional rows.
  static List<List<dynamic>> flattenAll(
    List<Map<String, dynamic>> jsonList,
    SchemaMapper mapper,
  ) {
    return jsonList.map((json) => flatten(json, mapper)).toList();
  }
}
