import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:flutter/material.dart';

const kFontFamily = 'Urbanist';

/// Typography from the spec (Urbanist, bundled).
abstract final class EventraText {
  static const heroTitle = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const sectionTitle = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: EventraPalette.textPrimary,
  );
  static const cardTitleOnPhoto = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static const cardTitle = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: EventraPalette.textPrimary,
  );
  static const detailsTitle = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: EventraPalette.textPrimary,
  );
  static const price = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: EventraPalette.primary,
  );
  static const body = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: EventraPalette.textSecondary,
  );
  static const caption = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: EventraPalette.textSecondary,
  );
  static const button = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

ThemeData buildEventraTheme() {
  const tokens = EventraTokens.light;
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: kFontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tokens.primary,
      primary: tokens.primary,
      surface: tokens.surface,
      error: tokens.error,
    ),
    scaffoldBackgroundColor: tokens.background,
  );
  return base.copyWith(
    extensions: const [tokens],
    textTheme: base.textTheme.apply(
      fontFamily: kFontFamily,
      bodyColor: tokens.textPrimary,
      displayColor: tokens.textPrimary,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
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
