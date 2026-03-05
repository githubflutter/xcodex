/// High-performance, schema-free dynamic data hub.
///
/// **Zero external dependencies** — uses only `dart:async` and `dart:core`.
///
/// All data is stored as `Map<dynamic, List<dynamic>>` using a C0…Cn
/// positional pattern where C0 is always the row's unique identifier.
///
/// ## Project Goals
///
/// 1. **Server-driven schema** — Define column mappings at runtime via JSON
/// 2. **Centralized data hub** — Single source of truth via `GlobalDataSet`
/// 3. **Centralized change notifier** — Reactive streams broadcast all mutations
/// 4. **Sync/async synchronization** — Unified stream interface for both
/// 5. **Custom JSON structure** — `JsonFlattener` + `SchemaMapper` for any format
/// 6. **LINQ-like queries** — `whereByC`, `orderByC`, `selectC`, string operators (`>=`, `contains`)
///
/// ## Example
///
/// ```dart
/// import 'package:xcodex/xcodex.dart';
///
/// // Create a table hub
/// final hub = GlobalDataSet().table('Users');
///
/// // Insert data (C0=id, C1=name, C2=status)
/// hub.upsert('u1', ['u1', 'Alice', 'Active']);
/// hub.upsert('u2', ['u2', 'Bob', 'Inactive']);
///
/// // Query with LINQ-style operators
/// final activeUsers = hub.current
///     .whereByC(2, '==', 'Active')
///     .orderByC(1);
///
/// // Listen to changes (reactive)
/// hub.stream$.listen((data) => print('Users changed: ${data.length}'));
/// ```
library xcodex;

export 'src/operator_engine.dart';
export 'src/mode_engine.dart';
export 'src/table_hub.dart';
export 'src/where_by_c.dart';
export 'src/schema_mapper.dart';
export 'src/json_flattener.dart';
export 'src/global_data_set.dart';
