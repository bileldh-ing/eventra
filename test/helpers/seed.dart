import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:eventra/features/events/data/backend/local_demo_backend.dart';
import 'package:eventra/features/events/data/backend/seed_source.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/seed_bundle.dart';

final String seedJson = File('assets/seed/events.json').readAsStringSync();

SeedBundle loadSeed() =>
    SeedBundle.fromJson(jsonDecode(seedJson) as Map<String, dynamic>);

AppDatabase memoryDb() => AppDatabase(NativeDatabase.memory());

LocalDemoBackend testBackend({
  AppDatabase? db,
  FaultConfig faults = FaultConfig.none,
}) => LocalDemoBackend(
  db: db ?? memoryDb(),
  seedSource: StringSeedSource(seedJson),
  latency: Duration.zero,
  faults: faults,
);
