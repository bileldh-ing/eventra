import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// App languages. Labels are endonyms, so they stay in their own language
/// whatever the current locale is.
enum AppLanguage {
  en('English', 'EN'),
  fr('Français', 'FR'),
  ar('العربية', 'AR');

  const AppLanguage(this.label, this.code);
  final String label;
  final String code;

  Locale get locale => Locale(name);

  /// Arabic lays the UI out right to left.
  bool get isRtl => this == AppLanguage.ar;
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
  ThemeMode.system => AppLocale.l10n.themeSystem,
  ThemeMode.light => AppLocale.l10n.themeLight,
  ThemeMode.dark => AppLocale.l10n.themeDark,
};
