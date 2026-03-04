/// High-performance, schema-free dynamic data hub.
///
/// All data is stored as `Map<dynamic, List<dynamic>>` using a C0…Cn
/// positional pattern where C0 is always the row's unique identifier.
library xcodex;

export 'src/operator_engine.dart';
export 'src/table_hub.dart';
export 'src/where_by_c.dart';
export 'src/schema_mapper.dart';
export 'src/json_flattener.dart';
export 'src/global_data_set.dart';
