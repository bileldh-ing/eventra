import 'package:shared_preferences/shared_preferences.dart';

/// Small synchronous settings store (onboarding flag, interests, home city).
/// Reads are synchronous; writes persist in the background.
abstract interface class PrefsStore {
  String? getString(String key);
  bool? getBool(String key);
  List<String>? getStringList(String key);
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, {required bool value});
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

/// shared_preferences-backed store, loaded once at startup.
class SharedPrefsStore implements PrefsStore {
  SharedPrefsStore(this._prefs);
  final SharedPreferences _prefs;

  static Future<SharedPrefsStore> load() async =>
      SharedPrefsStore(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// In-memory store for tests.
class MemoryPrefsStore implements PrefsStore {
  MemoryPrefsStore([Map<String, Object>? initial]) : values = {...?initial};
  final Map<String, Object> values;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  List<String>? getStringList(String key) =>
      (values[key] as List<Object?>?)?.cast<String>();

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> setBool(String key, {required bool value}) async =>
      values[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      values[key] = [...value];

  @override
  Future<void> remove(String key) async => values.remove(key);
}
