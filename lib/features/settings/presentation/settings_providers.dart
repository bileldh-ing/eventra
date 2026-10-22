import 'package:collection/collection.dart';
import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preference keys in the prefs store.
abstract final class SettingsKeys {
  static const themeMode = 'settings.themeMode';
  static const language = 'settings.language';
  static const eventReminders = 'settings.notif.reminders';
  static const orderUpdates = 'settings.notif.orders';
  static const recommendations = 'settings.notif.recommendations';
  static const personalizedFeed = 'settings.privacy.personalized';
}

/// Reads and persists [AppSettings]. Reads are synchronous (prefs are
/// loaded at startup), so the first frame already has the right theme.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final p = ref.watch(prefsStoreProvider);
    const d = AppSettings();
    return AppSettings(
      themeMode:
          ThemeMode.values.firstWhereOrNull(
            (m) => m.name == p.getString(SettingsKeys.themeMode),
          ) ??
          d.themeMode,
      language:
          AppLanguage.values.firstWhereOrNull(
            (l) => l.name == p.getString(SettingsKeys.language),
          ) ??
          d.language,
      eventReminders:
          p.getBool(SettingsKeys.eventReminders) ?? d.eventReminders,
      orderUpdates: p.getBool(SettingsKeys.orderUpdates) ?? d.orderUpdates,
      recommendations:
          p.getBool(SettingsKeys.recommendations) ?? d.recommendations,
      personalizedFeed:
          p.getBool(SettingsKeys.personalizedFeed) ?? d.personalizedFeed,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref
        .read(prefsStoreProvider)
        .setString(SettingsKeys.themeMode, mode.name);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await ref
        .read(prefsStoreProvider)
        .setString(SettingsKeys.language, language.name);
  }

  Future<void> setEventReminders({required bool value}) =>
      _bool(SettingsKeys.eventReminders, value, (s) {
        return s.copyWith(eventReminders: value);
      });

  Future<void> setOrderUpdates({required bool value}) => _bool(
    SettingsKeys.orderUpdates,
    value,
    (s) => s.copyWith(orderUpdates: value),
  );

  Future<void> setRecommendations({required bool value}) => _bool(
    SettingsKeys.recommendations,
    value,
    (s) => s.copyWith(recommendations: value),
  );

  Future<void> setPersonalizedFeed({required bool value}) => _bool(
    SettingsKeys.personalizedFeed,
    value,
    (s) => s.copyWith(personalizedFeed: value),
  );

  Future<void> _bool(
    String key,
    bool value,
    AppSettings Function(AppSettings) apply,
  ) async {
    state = apply(state);
    await ref.read(prefsStoreProvider).setBool(key, value: value);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
