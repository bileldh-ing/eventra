import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs [body] with real soft shadows (flutter_test draws them solid by
/// default) and restores the flag before the binding checks invariants.
Future<void> withRealShadows(Future<void> Function() body) async {
  debugDisableShadows = false;
  try {
    await body();
  } finally {
    debugDisableShadows = true;
  }
}

Future<void> expectGolden(Finder finder, String path) =>
    expectLater(finder, matchesGoldenFile(path));
