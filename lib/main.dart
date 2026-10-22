import 'package:eventra/app/app.dart';
import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/events/data/db/open_database.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPrefsStore.load();
  runApp(
    ProviderScope(
      // Show error states immediately with a Retry button instead of
      // Riverpod's silent automatic retries.
      retry: (retryCount, error) => null,
      overrides: [
        appDatabaseProvider.overrideWithValue(openAppDatabase()),
        prefsStoreProvider.overrideWithValue(prefs),
      ],
      child: const EventraApp(),
    ),
  );
}
