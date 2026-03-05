# xcodex API Documentation

`xcodex` is a schema-free, in-memory, reactive data hub for Dart applications.

- Runtime model: positional row format `C0..Cn`
- Core data type: `Map<dynamic, List<dynamic>>` (`HubData`)
- Reactive updates: broadcast stream on each mutation
- Query style: LINQ-like extension methods on `HubData`

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Public Exports](#public-exports)
3. [Type Definitions](#type-definitions)
4. [Mode Engine (Thin / Mini / Custom)](#mode-engine-thin--mini--custom)
5. [GlobalDataSet](#globaldataset)
6. [TableHub](#tablehub)
7. [WhereByC Extension](#wherebyc-extension)
8. [OperatorEngine](#operatorengine)
9. [SchemaMapper](#schemamapper)
10. [JsonFlattener](#jsonflattener)
11. [End-to-End Example](#end-to-end-example)
12. [Behavior Notes and Constraints](#behavior-notes-and-constraints)
13. [Testing Coverage](#testing-coverage)

---

## Core Concepts

### Positional row model
Each row is a `List<dynamic>`:

- `C0` = unique row id
- `C1..Cn` = payload columns

Example row:

```dart
['u1', 'Alice', 'Active', 120]
```

### Hub data model
Rows are stored in a map keyed by id (`C0`):

```dart
{
  'u1': ['u1', 'Alice', 'Active', 120],
  'u2': ['u2', 'Bob', 'Inactive', 95],
}
```

---

## Public Exports

The package exports these modules from `lib/xcodex.dart`:

- `operator_engine.dart`
- `mode_engine.dart`
- `table_hub.dart`
- `where_by_c.dart`
- `schema_mapper.dart`
- `json_flattener.dart`
- `global_data_set.dart`

Import with:

```dart
import 'package:xcodex/xcodex.dart';
```

---

## Type Definitions

### `typedef HubData = Map<dynamic, List<dynamic>>`

Defined in `table_hub.dart`.

Represents a complete in-memory table snapshot.

---

## Mode Engine (Thin / Mini / Custom)

Defined in `mode_engine.dart`.

This API adds lightweight shaping modes for `HubData`:

- **full**: keep full rows
- **thin**: keep first N columns (always keeps `C0`)
- **mini**: keep selected columns (always keeps `C0`)
- **custom**: user-defined transform (plus optional filter)

### Enum

#### `enum HubMode { full, thin, mini, custom }`

### Callback typedefs

#### `typedef HubRowTransformer = List<dynamic> Function(List<dynamic> row, dynamic key)`

#### `typedef HubRowPredicate = bool Function(List<dynamic> row, dynamic key)`

### Core API

#### `HubData applyMode(HubMode mode, {List<int>? miniColumns, int thinColumns = 2, HubRowTransformer? transform, HubRowPredicate? where})`

Rules:

- `HubMode.thin`: `thinColumns >= 1`
- `HubMode.mini`: `miniColumns` required and non-empty
- `HubMode.custom`: `transform` required
- `where` is optional row filter for all modes

### Convenience helpers

#### `HubData fullMode({HubRowPredicate? where})`
Returns all rows unchanged (new map instance).

#### `HubData thinMode({int columns = 2, HubRowPredicate? where})`
Returns the first `columns` indices per row.

#### `HubData miniMode(List<int> columns, {HubRowPredicate? where})`
Returns only selected indices and ensures index `0` is included.

#### `HubData customMode({required HubRowTransformer transform, HubRowPredicate? where})`
Applies user transform on each row. If transformed row is invalid for key contract,
the API normalizes the row so `row[0] == key`.

### Mode examples

```dart
final active = hub.current.whereByC(2, '==', 'Active');

// thin: keep C0..C1
final thin = active.thinMode(columns: 2);

// mini: keep C0 + C1 + C3
final mini = active.miniMode([1, 3]);

// custom: keep C0 + name + computed score
final custom = active.customMode(
  where: (row, _) => row[3] != null,
  transform: (row, key) => [key, row[1], (row[3] as int) * 10],
);
```

---

## GlobalDataSet

Singleton registry for table hubs.

### Constructor

```dart
factory GlobalDataSet()
```

Always returns the singleton instance.

### Methods

#### `TableHub table(String tableName)`
Gets an existing table hub or lazily creates one.

- Input: table name
- Output: `TableHub` instance bound to that table

#### `void disposeAll()`
Disposes all registered hubs and clears the registry.

Use when shutting down app-level resources.

---

## TableHub

Abstract reactive table store.

### Constructor

```dart
TableHub([HubData? data])
```

Optional seed data can be provided.

### Read API

#### `Stream<HubData> get stream$`
Broadcast stream emitting a new immutable snapshot after each mutation.

#### `HubData get current`
Current immutable snapshot.

#### `int get length`
Number of rows.

#### `bool get isEmpty`
Whether there are no rows.

### Write API

#### `void upsert(dynamic id, List<dynamic> row)`
Insert or update one row.

Contract:

- `row` must be non-empty
- `row[0] == id`

#### `void upsertAll(HubData rows)`
Insert/update many rows at once.

Contract for each entry:

- `entry.value` must be non-empty
- `entry.value[0] == entry.key`

#### `void remove(dynamic id)`
Remove row by id. No-op if id not found.

#### `void seed(HubData data)`
Replace all existing rows with provided data.

#### `void clear()`
Remove all rows.

### Lifecycle

#### `void dispose()`
Closes underlying stream controller. Must be called to avoid resource leaks.

---

## WhereByC Extension

Extension methods on `HubData` for filtering, sorting, projection, and aggregation.

> All methods return a new map and do not mutate the original input.

### Filtering

#### `HubData whereByC(int colIndex, String op, dynamic value)`
Keep rows where `row[colIndex] op value`.

#### `HubData whereAllByC(List<List<dynamic>> conditions)`
Logical AND over conditions.

Condition format per entry:

```dart
[colIndex, op, value]
```

#### `HubData whereAnyByC(List<List<dynamic>> conditions)`
Logical OR over conditions.

### Sorting

#### `HubData orderByC(int colIndex, {bool desc = false})`
Sort rows by one column.

- Column value must be `Comparable`
- Use `desc: true` for descending

### Projection

#### `HubData selectC(List<int> colIndices)`
Return rows containing only selected indices.

- If a requested index is out of range for a row, inserts `null` at that position.

### Aggregation

#### `Set<dynamic> distinctC(int colIndex)`
Unique values of a given column.

#### `Map<dynamic, int> countByC(int colIndex)`
Frequency map by column value.

---

## OperatorEngine

String-token operator evaluator.

### Supported operators

- `==`
- `!=`
- `>`
- `<`
- `>=`
- `<=`
- `contains`
- `startsWith`
- `endsWith`

### API

#### `static const Set<String> supportedOps`
Set of supported operator tokens.

#### `static bool evaluate(dynamic left, String op, dynamic right)`
Evaluates operator expression.

Semantics:

- Equality operators use normal Dart equality
- Relational operators use `Comparable.compareTo`
- String operators coerce both operands with `.toString()`

Throws:

- `ArgumentError` for unsupported operators
- `TypeError` when relational operands are not `Comparable`

---

## SchemaMapper

Maps logical field names to positional indices.

### Factory

#### `factory SchemaMapper.fromJsonSchema(Map<String, dynamic> schema)`
Builds mapping from schema values that are:

- `int` values (direct index)
- strings like `"C0"`, `"C1"`, ...
- numeric strings like `"0"`, `"1"`, ...

Unrecognized values are ignored.

### API

#### `int? getIndex(String key)`
Returns index for a field key, or `null`.

#### `Map<String, int> get mapping`
Read-only key-to-index map.

---

## JsonFlattener

Converts JSON maps into positional rows based on `SchemaMapper`.

### API

#### `static List<dynamic> flatten(Map<String, dynamic> json, SchemaMapper mapper)`
Builds a row where each mapped index is filled from JSON values.

Behavior:

- Allocates row length as `maxMappedIndex + 1`
- Missing mapped fields remain `null`
- Asserts `C0` is not null for `TableHub` compatibility

#### `static List<List<dynamic>> flattenAll(List<Map<String, dynamic>> jsonList, SchemaMapper mapper)`
Maps `flatten(...)` across a list of JSON objects.

---

## End-to-End Example

```dart
import 'package:xcodex/xcodex.dart';

void main() {
  // 1) Define schema from server metadata
  final mapper = SchemaMapper.fromJsonSchema({
    'Id': 'C0',
    'Name': 'C1',
    'Status': 'C2',
    'Amount': 'C3',
  });

  // 2) Flatten incoming JSON rows
  final raw = [
    {'Id': 'u1', 'Name': 'Alice', 'Status': 'Active', 'Amount': 150},
    {'Id': 'u2', 'Name': 'Bob', 'Status': 'Inactive', 'Amount': 90},
    {'Id': 'u3', 'Name': 'Carla', 'Status': 'Active', 'Amount': 210},
  ];

  final rows = JsonFlattener.flattenAll(raw, mapper);

  // 3) Seed table hub
  final hub = GlobalDataSet().table('Users');
  hub.seed({for (final row in rows) row[0]: row});

  // 4) Query
  final result = hub.current
      .whereByC(2, '==', 'Active')
      .whereByC(3, '>=', 150)
      .orderByC(3, desc: true)
      .selectC([0, 1, 3]);

  print(result);

  // 5) Reactive updates
  final sub = hub.stream$.listen((snapshot) {
    print('Rows: ${snapshot.length}');
  });

  hub.upsert('u4', ['u4', 'Drew', 'Pending', 120]);

  sub.cancel();
  GlobalDataSet().disposeAll();
}
```

---

## Behavior Notes and Constraints

1. **C0 identity contract is strict**
   - `upsert` / `upsertAll` assert that key matches `row[0]`.

2. **Index-based access is unchecked at compile time**
   - Incorrect indices can cause runtime range/type errors.

3. **Map ordering behavior**
   - Results are maps; sorted operations rely on insertion order of returned map.

4. **Immutability of snapshots**
   - `TableHub` emits unmodifiable map snapshots.
   - Individual rows inserted are stored as unmodifiable lists.

5. **Disposal required**
   - Call `dispose()` on hubs or `disposeAll()` on `GlobalDataSet` during teardown.

---

## Testing Coverage

Current tests validate:

- Operator semantics and failure behavior (`operator_engine_test.dart`)
- Query extension behavior (`where_by_c_test.dart`)
  - filtering (`whereByC`, `whereAllByC`, `whereAnyByC`)
  - sorting (`orderByC` asc/desc)
  - projection (`selectC`)
  - aggregations (`distinctC`, `countByC`)
  - chained query composition
- Mode shaping behavior (`mode_engine_test.dart`)
  - `fullMode`, `thinMode`, `miniMode`, `customMode`
  - validation/error paths for mode requirements

---

If you want, this can be split into:

- `docs/api/core.md`
- `docs/api/query.md`
- `docs/api/schema.md`

and linked from a generated `README.md` index.