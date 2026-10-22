import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/core/storage/secure_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in main() with the loaded shared_preferences store.
final prefsStoreProvider = Provider<PrefsStore>(
  (ref) => throw StateError('prefsStoreProvider must be overridden'),
);

final secureStoreProvider = Provider<SecureStore>(
  (ref) => const FlutterSecureStore(),
);
