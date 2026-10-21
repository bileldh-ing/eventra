import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Raw palette from the design spec. Prefer reading colors through
/// [EventraTokens] (via `context.tokens`) inside widgets.
abstract final class EventraPalette {
  static const primary = Color(0xFFBC47F5);
  static const primaryLight = Color(0xFFE58CFF);
  static const primaryDeep = Color(0xFFB83BF4);
  static const background = Color(0xFFF7F1FC);
  static const sheet = Color(0xFFF9F3FE);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1530);
  static const textSecondary = Color(0xFF6F6A80);
  static const textHint = Color(0xFF9A95AA);
  static const accentOrange = Color(0xFFF6A15B);
  static const notificationRed = Color(0xFFFF3D3D);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);

  /// rgba(255,255,255,0.22)
  static const glassFill = Color(0x38FFFFFF);

  /// rgba(255,255,255,0.38)
  static const glassBorder = Color(0x61FFFFFF);

  static const headerTopLeft = Color(0xFFC86CF2);
  static const headerMiddle = Color(0xFFB77DF0);
  static const headerRight = Color(0xFF8DA7EE);
  static const headerGlow = Color(0xFFA9D9F2);
}

/// Spacing scale 4/8/12/16/24/32.
@immutable
class EventraSpacing {
  const EventraSpacing();
  double get xs => 4;
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 24;
  double get xxl => 32;
}

/// Corner radii from the spec's `shapes` section.
@immutable
class EventraRadii {
  const EventraRadii();
  double get header => 48;
  double get eventCard => 32;
  double get sheet => 36;
  double get listCard => 28;
  double get previewCard => 28;
  double get miniMap => 24;
  double get thumbnail => 20;
  double get pill => 999;
  double get navPill => 36;
}

/// Motion durations and curves.
@immutable
class EventraMotion {
  const EventraMotion();
  Duration get fast => const Duration(milliseconds: 150);
  Duration get medium => const Duration(milliseconds: 280);
  Duration get slow => const Duration(milliseconds: 450);
  Duration get pulse => const Duration(milliseconds: 1800);
  Curve get standard => Curves.easeOutCubic;
  Curve get emphasized => Curves.easeInOutCubicEmphasized;
  Curve get spring => Curves.elasticOut;
}

/// Design tokens exposed as a [ThemeExtension].
@immutable
class EventraTokens extends ThemeExtension<EventraTokens> {
  const EventraTokens({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.sheet,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.accentOrange,
    required this.notificationRed,
    required this.success,
    required this.error,
    required this.glassFill,
    required this.glassBorder,
    this.spacing = const EventraSpacing(),
    this.radii = const EventraRadii(),
    this.motion = const EventraMotion(),
    this.glassBlurSigma = 14,
    this.buttonHeight = 58,
    this.navPillHeight = 72,
  });

  static const light = EventraTokens(
    primary: EventraPalette.primary,
    primaryLight: EventraPalette.primaryLight,
    background: EventraPalette.background,
    sheet: EventraPalette.sheet,
    surface: EventraPalette.surface,
    textPrimary: EventraPalette.textPrimary,
    textSecondary: EventraPalette.textSecondary,
    textHint: EventraPalette.textHint,
    accentOrange: EventraPalette.accentOrange,
    notificationRed: EventraPalette.notificationRed,
    success: EventraPalette.success,
    error: EventraPalette.error,
    glassFill: EventraPalette.glassFill,
    glassBorder: EventraPalette.glassBorder,
  );

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color sheet;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color accentOrange;
  final Color notificationRed;
  final Color success;
  final Color error;
  final Color glassFill;
  final Color glassBorder;
  final EventraSpacing spacing;
  final EventraRadii radii;
  final EventraMotion motion;
  final double glassBlurSigma;
  final double buttonHeight;
  final double navPillHeight;

  /// centerLeft -> centerRight: #E58CFF -> #B83BF4
  LinearGradient get primaryGradient => const LinearGradient(
    colors: [EventraPalette.primaryLight, EventraPalette.primaryDeep],
  );

  /// Diagonal header gradient with the soft cyan glow at the bottom.
  LinearGradient get headerGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      EventraPalette.headerTopLeft,
      EventraPalette.headerMiddle,
      EventraPalette.headerRight,
      EventraPalette.headerGlow,
    ],
    stops: [0, 0.45, 0.82, 1],
  );

  /// rgba(188,71,245,0.35), blur 24, offset (0,10)
  List<BoxShadow> get primaryGlow => const [
    BoxShadow(color: Color(0x59BC47F5), blurRadius: 24, offset: Offset(0, 10)),
  ];

  /// Soft lavender shadow used by white cards, chips and the nav pill.
  List<BoxShadow> get softShadow => const [
    BoxShadow(color: Color(0x1A8A4FC8), blurRadius: 24, offset: Offset(0, 8)),
  ];

  @override
  EventraTokens copyWith({Color? primary, Color? background}) {
    return EventraTokens(
      primary: primary ?? this.primary,
      primaryLight: primaryLight,
      background: background ?? this.background,
      sheet: sheet,
      surface: surface,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textHint: textHint,
      accentOrange: accentOrange,
      notificationRed: notificationRed,
      success: success,
      error: error,
      glassFill: glassFill,
      glassBorder: glassBorder,
      spacing: spacing,
      radii: radii,
      motion: motion,
      glassBlurSigma: glassBlurSigma,
      buttonHeight: buttonHeight,
      navPillHeight: navPillHeight,
    );
  }

  @override
  EventraTokens lerp(covariant EventraTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return EventraTokens(
      primary: c(primary, other.primary),
      primaryLight: c(primaryLight, other.primaryLight),
      background: c(background, other.background),
      sheet: c(sheet, other.sheet),
      surface: c(surface, other.surface),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textHint: c(textHint, other.textHint),
      accentOrange: c(accentOrange, other.accentOrange),
      notificationRed: c(notificationRed, other.notificationRed),
      success: c(success, other.success),
      error: c(error, other.error),
      glassFill: c(glassFill, other.glassFill),
      glassBorder: c(glassBorder, other.glassBorder),
      spacing: spacing,
      radii: radii,
      motion: motion,
      glassBlurSigma: lerpDouble(glassBlurSigma, other.glassBlurSigma, t)!,
      buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t)!,
      navPillHeight: lerpDouble(navPillHeight, other.navPillHeight, t)!,
    );
  }
}

extension EventraThemeX on BuildContext {
  EventraTokens get tokens =>
      Theme.of(this).extension<EventraTokens>() ?? EventraTokens.light;
}
