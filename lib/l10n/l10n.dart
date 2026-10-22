import 'package:eventra/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Intl;

export 'package:eventra/l10n/gen/app_localizations.dart';

/// Locales the app ships, in Settings order.
const kSupportedLocales = [Locale('en'), Locale('fr'), Locale('ar')];

/// The active app locale outside the widget tree.
///
/// Widgets read strings with `context.l10n` so they rebuild on a language
/// change. Pure-Dart code (validators, domain messages, formatters) runs
/// without a [BuildContext]; it reads [AppLocale.l10n], which follows the
/// same locale because `EventraApp` calls [AppLocale.set] whenever the
/// language setting changes. This mirrors how `intl` itself keeps a global
/// `Intl.defaultLocale`.
abstract final class AppLocale {
  static Locale _current = const Locale('en');
  static AppLocalizations _l10n = lookupAppLocalizations(_current);

  static Locale get current => _current;

  /// Strings for the active locale.
  static AppLocalizations get l10n => _l10n;

  /// Language tag for `intl` formatters ('en', 'fr', 'ar').
  static String get tag => _current.languageCode;

  static bool get isEnglish => _current.languageCode == 'en';

  static void set(Locale locale) {
    if (locale == _current) return;
    _current = locale;
    _l10n = lookupAppLocalizations(locale);
    Intl.defaultLocale = locale.languageCode;
  }
}

extension L10nX on BuildContext {
  /// Localized strings for this subtree.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// True when the ambient text direction is right-to-left.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
