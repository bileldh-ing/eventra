import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:flutter/material.dart';

const kFontFamily = 'Urbanist';

/// Arabic glyphs are not in Urbanist; text falls back to the bundled
/// Noto Sans Arabic (SIL OFL 1.1, see assets/fonts/OFL-NotoSansArabic.txt).
const kArabicFontFamily = 'NotoSansArabic';
const List<String> kFontFallback = [kArabicFontFamily];

/// Typography from the spec (Urbanist, bundled).
abstract final class EventraText {
  static const heroTitle = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const sectionTitle = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: EventraPalette.textPrimary,
  );
  static const cardTitleOnPhoto = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static const cardTitle = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: EventraPalette.textPrimary,
  );
  static const detailsTitle = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: EventraPalette.textPrimary,
  );
  static const price = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: EventraPalette.primary,
  );
  static const body = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: EventraPalette.textSecondary,
  );
  static const caption = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: EventraPalette.textSecondary,
  );
  static const button = TextStyle(
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

/// [EventraText] recolored for the active [EventraTokens], so the same
/// typography reads correctly in light and dark mode. Read it through
/// `context.text`.
@immutable
class EventraTextStyles {
  factory EventraTextStyles.of(EventraTokens t) =>
      identical(t, EventraTokens.light)
      ? light
      : identical(t, EventraTokens.dark)
      ? dark
      : EventraTextStyles._(t);
  EventraTextStyles._(EventraTokens t)
    : heroTitle = EventraText.heroTitle,
      sectionTitle = EventraText.sectionTitle.copyWith(color: t.textPrimary),
      cardTitleOnPhoto = EventraText.cardTitleOnPhoto,
      cardTitle = EventraText.cardTitle.copyWith(color: t.textPrimary),
      detailsTitle = EventraText.detailsTitle.copyWith(color: t.textPrimary),
      price = EventraText.price.copyWith(color: t.primary),
      body = EventraText.body.copyWith(color: t.textSecondary),
      caption = EventraText.caption.copyWith(color: t.textSecondary),
      button = EventraText.button;

  static final light = EventraTextStyles._(EventraTokens.light);
  static final dark = EventraTextStyles._(EventraTokens.dark);

  final TextStyle heroTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitleOnPhoto;
  final TextStyle cardTitle;
  final TextStyle detailsTitle;
  final TextStyle price;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle button;
}

extension EventraTextX on BuildContext {
  /// Typography in the current theme's colors.
  EventraTextStyles get text => EventraTextStyles.of(tokens);
}

/// Builds the app theme for [brightness]. Every screen reads colors from
/// [EventraTokens] (light or dark palette) and typography from
/// [EventraTextStyles].
ThemeData buildEventraTheme({Brightness brightness = Brightness.light}) {
  final tokens = EventraTokens.forBrightness(brightness);
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: kFontFamily,
    fontFamilyFallback: kFontFallback,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tokens.primary,
      brightness: brightness,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.surfaceMuted,
      outline: tokens.outline,
      primary: tokens.primary,
      surface: tokens.surface,
      error: tokens.error,
    ),
    scaffoldBackgroundColor: tokens.background,
  );
  return base.copyWith(
    extensions: [tokens],
    textTheme: base.textTheme.apply(
      fontFamily: kFontFamily,
      bodyColor: tokens.textPrimary,
      displayColor: tokens.textPrimary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: tokens.isDark ? tokens.surfaceMuted : null,
      contentTextStyle: tokens.isDark
          ? TextStyle(color: tokens.textPrimary, fontFamily: kFontFamily)
          : null,
    ),
    dividerColor: tokens.outline,
    dividerTheme: DividerThemeData(color: tokens.outline),
    dialogTheme: DialogThemeData(backgroundColor: tokens.sheet),
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.background,
      foregroundColor: tokens.textPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: IconThemeData(color: tokens.textPrimary),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.sheet,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radii.sheet),
        ),
      ),
    ),
  );
}
