import 'package:rxdart/rxdart.dart';

/// Row storage type: keyed by C0 (id), value is positional columns [C0, C1, …, Cn].
typedef HubData = Map<dynamic, List<dynamic>>;

/// Abstract reactive data store that wraps a [BehaviorSubject] around a
/// column-positional [HubData] map.
///
/// Subclass this to create domain-specific hubs (e.g. `OrdersHub`,
/// `UsersHub`) without defining POJOs — all data stays in the C0…Cn
/// positional pattern.
///
/// ```dart
/// class OrdersHub extends TableHub {
///   OrdersHub() : super();
/// }
///
/// final hub = OrdersHub();
/// hub.upsert('order-1', ['order-1', 'Active', 150.0, DateTime.now()]);
/// hub.stream$.listen((data) => print('rows: ${data.length}'));
/// ```
abstract class TableHub {
  /// Creates a [TableHub] seeded with optional initial [data].
  TableHub([HubData? data])
    : _subject = BehaviorSubject<HubData>.seeded(data ?? <dynamic, List<dynamic>>{});

  final BehaviorSubject<HubData> _subject;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// A broadcast [ValueStream] that emits on every mutation.
  ValueStream<HubData> get stream$ => _subject.stream;

  /// The current snapshot (synchronous access).
  HubData get current => _subject.value;

  /// Number of rows in the current snapshot.
  int get length => current.length;

  /// Whether the hub contains zero rows.
  bool get isEmpty => current.isEmpty;

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Inserts or updates the row identified by [id] (C0).
  ///
  /// [row] must include [id] at index 0.
  void upsert(dynamic id, List<dynamic> row) {
    assert(
      row.isNotEmpty && row[0] == id,
      'row[0] (C0) must equal the supplied id',
    );
    _emit({...current, id: List<dynamic>.unmodifiable(row)});
  }

  /// Inserts or updates multiple rows at once.
  void upsertAll(HubData rows) {
    final next = {...current};
    for (final entry in rows.entries) {
      assert(
        entry.value.isNotEmpty && entry.value[0] == entry.key,
        'row[0] (C0) must equal the key for every entry',
      );
      next[entry.key] = List<dynamic>.unmodifiable(entry.value);
    }
    _emit(next);
  }

  /// Removes the row with the given [id]. No-op if absent.
  void remove(dynamic id) {
    if (!current.containsKey(id)) return;
    final next = {...current}..remove(id);
    _emit(next);
  }

  /// Replaces all data with [data]. Existing rows are discarded.
  void seed(HubData data) {
    final immutable = <dynamic, List<dynamic>>{
      for (final e in data.entries)
        e.key: List<dynamic>.unmodifiable(e.value),
    };
    _emit(immutable);
  }

  /// Removes all rows.
  void clear() => _emit(<dynamic, List<dynamic>>{});

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Closes the underlying [BehaviorSubject]. Must be called to prevent leaks.
  void dispose() => _subject.close();

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  void _emit(HubData next) => _subject.add(Map<dynamic, List<dynamic>>.unmodifiable(next));
}
