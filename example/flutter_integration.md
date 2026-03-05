# Flutter Integration Example

Since `xcodex` is a pure Dart package with **zero external dependencies**, it works seamlessly with Flutter's `StreamBuilder` and any stream manipulation library you choose to add.

Here is an example of how you can use the `GlobalDataSet` and `TableHub` in your Flutter application:

```dart
import 'package:flutter/material.dart';
import 'package:xcodex/xcodex.dart';

/// A template Flutter StreamBuilder widget connecting to GlobalDataSet.
class PositionalListWidget extends StatelessWidget {
  final String tableName;
  final SchemaMapper schemaMapper;

  const PositionalListWidget({
    Key? key,
    required this.tableName,
    required this.schemaMapper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Connect to the global TableHub
    final tableHub = GlobalDataSet().table(tableName);

    return StreamBuilder<HubData>(
      // 2. Listen to the reactive stream
      stream: tableHub.stream$,
      // 3. Provide the initial synchronous state
      initialData: tableHub.current,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data found.'));
        }

        final hubData = snapshot.data!;
        
        // Convert the TableHub map into an iterable of rows.
        final rows = hubData.values.toList();

        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final List<dynamic> row = rows[index];

            // 4. Safely extract data using the SchemaMapper positional indices.
            final idIndex = schemaMapper.getIndex('Id') ?? 0;
            final nameIndex = schemaMapper.getIndex('Name') ?? 1;

            final id = row.length > idIndex ? row[idIndex] : 'N/A';
            final name = row.length > nameIndex ? row[nameIndex] : 'Unknown Name';

            return ListTile(
              title: Text(name.toString()),
              subtitle: Text('ID: $id'),
            );
          },
        );
      },
    );
  }
}
```
