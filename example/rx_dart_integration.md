# RxDart & Stream Transform Integration

Because we updated `TableHub.stream$` to expose a standard native Dart `Stream<HubData>` using modern `dart:async`, **all of RxDart's powerful extension methods work entirely out-of-the-box via Dart Extensions!**

You don't need `TableHub` to be tightly coupled or wrapped in older RxDart classes like `Observable`. The modern, optimized approach in Dart is that RxDart operators are just extension methods on the core `Stream` class.

### 1. Combine Latest Example
If you want to combine streams from two different tables in `GlobalDataSet`:

```dart
import 'package:rxdart/rxdart.dart';
import 'package:xcodex/xcodex.dart';

void main() {
  final usersHub = GlobalDataSet().table('Users');
  final ordersHub = GlobalDataSet().table('Orders');

  // Use CombineLatestStream.combine2 (modern rxdart API)
  final combinedStream = CombineLatestStream.combine2(
    usersHub.stream$,
    ordersHub.stream$,
    (users, orders) {
      return {
        'totalUsers': users.length,
        'totalOrders': orders.length,
      };
    },
  );

  combinedStream.listen(print);
}
```

### 2. Stream Capabilities (Debounce, MapNotNull, Throttle)
Use RxDart's extension methods directly on `stream$`:

```dart
import 'package:rxdart/rxdart.dart';
import 'package:xcodex/xcodex.dart';

void listenToTraffic() {
  final hub = GlobalDataSet().table('Traffic');

  // All extension methods (debounceTime, whereType, etc.) are available!
  hub.stream$
      .debounceTime(const Duration(milliseconds: 500))
      .where((data) => data.isNotEmpty)
      .listen((filteredData) {
    print('Heavy traffic data updated: ${filteredData.length} records');
  });
}
```

### 3. Alternative: `stream_transform`
We also added `stream_transform` (the official async package by the Dart team) which provides a more lightweight, heavily optimized set of operators for modern Dart:

```dart
import 'package:stream_transform/stream_transform.dart';
import 'package:xcodex/xcodex.dart';

void optimizedStream() {
  final hub = GlobalDataSet().table('Analytics');

  hub.stream$
      // Official Dart team's optimized throttle
      .throttle(const Duration(seconds: 1))
      .listen((data) => print('Analytics updated.'));
}
```

Because `table.stream$` is now just a core `Stream<HubData>`, **any** stream manipulation library will work perfectly without needing to lock RxDart into the core internals!
