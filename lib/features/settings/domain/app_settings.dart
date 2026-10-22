import 'package:flutter/material.dart';

/// App languages. The choice is persisted now; strings are wired up with
/// the localization pass.
enum AppLanguage {
  en('English', 'EN'),
  fr('Français', 'FR'),
  ar('العربية', 'AR');

  const AppLanguage(this.label, this.code);
  final String label;
  final String code;
}

/// User preferences, persisted per device.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.en,
    this.eventReminders = true,
    this.orderUpdates = true,
    this.recommendations = true,
    this.personalizedFeed = true,
  });

  final ThemeMode themeMode;
  final AppLanguage language;

  /// Local reminders 24 h and 2 h before events with a ticket.
  final bool eventReminders;

  /// Inbox items for order confirmations and refunds.
  final bool orderUpdates;

  /// Inbox items for new events and price drops.
  final bool recommendations;

  /// Privacy: use interests and saves to rank the feed.
  final bool personalizedFeed;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? eventReminders,
    bool? orderUpdates,
    bool? recommendations,
    bool? personalizedFeed,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    eventReminders: eventReminders ?? this.eventReminders,
    orderUpdates: orderUpdates ?? this.orderUpdates,
    recommendations: recommendations ?? this.recommendations,
    personalizedFeed: personalizedFeed ?? this.personalizedFeed,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.language == language &&
      other.eventReminders == eventReminders &&
      other.orderUpdates == orderUpdates &&
      other.recommendations == recommendations &&
      other.personalizedFeed == personalizedFeed;

  @override
  int get hashCode => Object.hash(
    themeMode,
    language,
    eventReminders,
    orderUpdates,
    recommendations,
    personalizedFeed,
  );
}

String themeModeLabel(ThemeMode m) => switch (m) {
  ThemeMode.system => 'System',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};
