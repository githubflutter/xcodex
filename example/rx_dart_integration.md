# Pure Dart Stream Integration

**xcodex** uses only `dart:async` and `dart:core` — zero external dependencies. All stream operations use native Dart patterns.

## Stream Operators via Extension Methods

You can add your own extension methods or use inline `StreamTransformer` for operations like debounce, throttle, and filtering.

### 1. Combine Latest Example (Pure Dart)

Combine streams from multiple tables using `StreamGroup` or manual merging:

```dart
import 'dart:async';
import 'package:xcodex/xcodex.dart';

void main() {
  final usersHub = GlobalDataSet().table('Users');
  final ordersHub = GlobalDataSet().table('Orders');

  // Pure Dart: Combine latest using StreamController
  final combinedController = StreamController<Map<String, int>>.broadcast();
  
  Map<dynamic, List<dynamic>>? latestUsers;
  Map<dynamic, List<dynamic>>? latestOrders;

  usersHub.stream$.listen((data) {
    latestUsers = data;
    if (latestOrders != null) {
      combinedController.add({
        'totalUsers': latestUsers!.length,
        'totalOrders': latestOrders!.length,
      });
    }
  });

  ordersHub.stream$.listen((data) {
    latestOrders = data;
    if (latestUsers != null) {
      combinedController.add({
        'totalUsers': latestUsers!.length,
        'totalOrders': latestOrders!.length,
      });
    }
  });

  combinedController.stream.listen(print);
}
```

### 2. Debounce/Throttle with StreamTransformer

Create reusable transformers for common operations:

```dart
import 'dart:async';
import 'package:xcodex/xcodex.dart';

/// Debounce transformer — emits only after [duration] of silence.
StreamTransformer<T, T> debounceTransformer<T>(Duration duration) {
  return StreamTransformer<T, T>.fromHandlers(
    handleData: (data, sink) {
      // Cancel previous timer
      _timer?.cancel();
      _timer = Timer(duration, () => sink.add(data));
    },
  );
}

Timer? _timer;

void listenToTraffic() {
  final hub = GlobalDataSet().table('Traffic');

  // Apply debounce using pure Dart transformer
  hub.stream$
      .transform(debounceTransformer(const Duration(milliseconds: 500)))
      .where((data) => data.isNotEmpty)
      .listen((filteredData) {
    print('Traffic data updated: ${filteredData.length} records');
  });
}
```

### 3. Throttle Example

```dart
import 'dart:async';
import 'package:xcodex/xcodex.dart';

/// Throttle transformer — emits first value, then ignores for [duration].
StreamTransformer<T, T> throttleTransformer<T>(Duration duration) {
  DateTime? lastEmit;

  return StreamTransformer<T, T>.fromHandlers(
    handleData: (data, sink) {
      final now = DateTime.now();
      if (lastEmit == null || now.difference(lastEmit!) >= duration) {
        lastEmit = now;
        sink.add(data);
      }
    },
  );
}

void optimizedStream() {
  final hub = GlobalDataSet().table('Analytics');

  hub.stream$
      .transform(throttleTransformer(const Duration(seconds: 1)))
      .listen((data) => print('Analytics updated.'));
}
```

### 4. Using with StreamBuilder (Flutter)

Since `stream$` is a standard `Stream<HubData>`, it works directly with Flutter:

```dart
import 'package:flutter/material.dart';
import 'package:xcodex/xcodex.dart';

StreamBuilder<HubData>(
  stream: hub.stream$,
  initialData: hub.current,
  builder: (context, snapshot) {
    // Build your UI
  },
)
```

## Why Pure Dart?

- ✅ **Zero external dependencies** — no version conflicts
- ✅ **Full control** — write only the transformers you need
- ✅ **Smaller bundle size** — no transitive dependencies
- ✅ **Compatible with everything** — works with RxDart, stream_transform, or any stream library if you choose to add them

## Optional: Add RxDart Yourself

If you need advanced operators, simply add `rxdart` to your project:

```yaml
dependencies:
  xcodex: ^0.1.0
  rxdart: ^0.28.0
```

Then use RxDart extension methods directly on `stream$`:

```dart
import 'package:rxdart/rxdart.dart';
import 'package:xcodex/xcodex.dart';

hub.stream$
    .debounceTime(Duration(milliseconds: 500))
    .distinct()
    .listen((data) => print(data));
```
