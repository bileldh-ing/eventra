import 'package:flutter/services.dart';

/// Where the seed JSON comes from (bundled asset in the app, a file in tests).
// One method today; kept as an interface so a remote seed can plug in.
// ignore: one_member_abstracts
abstract interface class SeedSource {
  Future<String> load();
}

class AssetSeedSource implements SeedSource {
  const AssetSeedSource([this.path = 'assets/seed/events.json']);
  final String path;

  @override
  Future<String> load() => rootBundle.loadString(path);
}

class StringSeedSource implements SeedSource {
  const StringSeedSource(this.json);
  final String json;

  @override
  Future<String> load() async => json;
}
