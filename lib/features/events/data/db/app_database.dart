import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Events are stored as their JSON payload plus indexed columns used for
/// filtering and sorting.
@DataClassName('EventRow')
class EventRows extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  DateTimeColumn get startAt => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get payload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FavoriteRow')
class FavoriteRows extends Table {
  TextColumn get eventId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}

@DataClassName('MetaRow')
class MetaRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [EventRows, FavoriteRows, MetaRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  Future<int> eventCount() async {
    final count = eventRows.id.count();
    final row = await (selectOnly(eventRows)..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> replaceEvents(List<EventRowsCompanion> rows) =>
      transaction(() async {
        await delete(eventRows).go();
        await batch((b) => b.insertAll(eventRows, rows));
      });

  Future<List<EventRow>> allEvents() =>
      (select(eventRows)..orderBy([(t) => OrderingTerm.asc(t.startAt)])).get();

  Future<EventRow?> eventById(String id) =>
      (select(eventRows)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Set<String>> watchFavoriteIds() => select(
    favoriteRows,
  ).watch().map((rows) => {for (final r in rows) r.eventId});

  Future<Set<String>> favoriteIds() async => {
    for (final r in await select(favoriteRows).get()) r.eventId,
  };

  /// Toggles a favorite; returns the new state (true = saved).
  Future<bool> toggleFavorite(String eventId, DateTime now) =>
      transaction(() async {
        final existing = await (select(
          favoriteRows,
        )..where((t) => t.eventId.equals(eventId))).getSingleOrNull();
        if (existing != null) {
          await (delete(
            favoriteRows,
          )..where((t) => t.eventId.equals(eventId))).go();
          return false;
        }
        await into(favoriteRows).insert(
          FavoriteRowsCompanion.insert(eventId: eventId, createdAt: now),
        );
        return true;
      });

  Future<String?> readMeta(String key) async => (await (select(
    metaRows,
  )..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> writeMeta(String key, String value) => into(
    metaRows,
  ).insertOnConflictUpdate(MetaRowsCompanion.insert(key: key, value: value));
}
