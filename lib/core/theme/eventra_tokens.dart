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

/// Dark palette (Phase 8b). Deep aubergine surfaces keep the brand's purple
/// cast; text and primary are lifted so body copy clears WCAG AA (4.5:1) on
/// every surface and the primary clears 3:1 for large text and icons.
abstract final class EventraDarkPalette {
  static const primary = Color(0xFFC86DF8);
  static const primaryLight = Color(0xFFE9A2FF);
  static const background = Color(0xFF0F0B19);
  static const sheet = Color(0xFF191326);
  static const surface = Color(0xFF1F1830);
  static const surfaceMuted = Color(0xFF2A2240);
  static const outline = Color(0xFF3A3152);
  static const textPrimary = Color(0xFFF4EFFC);
  static const textSecondary = Color(0xFFB9B1CC);
  static const textHint = Color(0xFF8C85A2);
  static const accentOrange = Color(0xFFF7AE70);
  static const notificationRed = Color(0xFFFF5A5A);
  static const success = Color(0xFF34D399);
  static const error = Color(0xFFF87171);
  static const glassFill = Color(0x2EFFFFFF);
  static const glassBorder = Color(0x3DFFFFFF);
  static const headerTopLeft = Color(0xFF7A2FA8);
  static const headerMiddle = Color(0xFF5E3AA3);
  static const headerRight = Color(0xFF3B4E98);
  static const headerGlow = Color(0xFF2A5F7C);
  static const mapBackground = Color(0xFF1B1726);
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
    this.surfaceMuted = const Color(0xFFF6F4F9),
    this.outline = const Color(0xFFEDE6F5),
    this.disabled = const Color(0xFFD9D2E3),
    this.skeletonBase = const Color(0xFFEDE4F6),
    this.skeletonHighlight = const Color(0xFFFBF7FE),
    this.mapBackground = const Color(0xFFF2F2F0),
    this.navInactive = const Color(0xFF3B3650),
    this.shadowTint = const Color(0xFF8A4FC8),
    this.headerColors = const [
      EventraPalette.headerTopLeft,
      EventraPalette.headerMiddle,
      EventraPalette.headerRight,
      EventraPalette.headerGlow,
    ],
    this.isDark = false,
    this.spacing = const EventraSpacing(),
    this.radii = const EventraRadii(),
    this.motion = const EventraMotion(),
    this.glassBlurSigma = 14,
    this.buttonHeight = 58,
    this.navPillHeight = 72,
  });

  /// Tokens for [brightness].
  static EventraTokens forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

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

  static const dark = EventraTokens(
    primary: EventraDarkPalette.primary,
    primaryLight: EventraDarkPalette.primaryLight,
    background: EventraDarkPalette.background,
    sheet: EventraDarkPalette.sheet,
    surface: EventraDarkPalette.surface,
    textPrimary: EventraDarkPalette.textPrimary,
    textSecondary: EventraDarkPalette.textSecondary,
    textHint: EventraDarkPalette.textHint,
    accentOrange: EventraDarkPalette.accentOrange,
    notificationRed: EventraDarkPalette.notificationRed,
    success: EventraDarkPalette.success,
    error: EventraDarkPalette.error,
    glassFill: EventraDarkPalette.glassFill,
    glassBorder: EventraDarkPalette.glassBorder,
    surfaceMuted: EventraDarkPalette.surfaceMuted,
    outline: EventraDarkPalette.outline,
    disabled: Color(0xFF3F3757),
    skeletonBase: Color(0xFF241D35),
    skeletonHighlight: Color(0xFF332A48),
    mapBackground: EventraDarkPalette.mapBackground,
    navInactive: Color(0xFFCFC7E2),
    shadowTint: Color(0xFF000000),
    headerColors: [
      EventraDarkPalette.headerTopLeft,
      EventraDarkPalette.headerMiddle,
      EventraDarkPalette.headerRight,
      EventraDarkPalette.headerGlow,
    ],
    isDark: true,
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

  /// Recessed surface: sold-out rows, inputs, chips at rest.
  final Color surfaceMuted;

  /// Hairlines, dividers, strength-meter tracks.
  final Color outline;

  /// Disabled button fill and stepper buttons.
  final Color disabled;
  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Behind map tiles while they load.
  final Color mapBackground;

  /// Inactive nav pill icons.
  final Color navInactive;

  /// Hue of soft shadows (lavender in light, black in dark).
  final Color shadowTint;
  final List<Color> headerColors;
  final bool isDark;
  final EventraSpacing spacing;
  final EventraRadii radii;
  final EventraMotion motion;
  final double glassBlurSigma;
  final double buttonHeight;
  final double navPillHeight;

  /// Brightness these tokens were made for.
  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  /// Shadow color at [alpha], tinted for the current mode (dark mode needs a
  /// stronger, neutral shadow to read against deep surfaces).
  Color shadow(double alpha) =>
      shadowTint.withValues(alpha: isDark ? (alpha * 3).clamp(0, 0.6) : alpha);

  /// [light] as designed in light mode; in dark mode a neutral shadow at
  /// [darkAlpha] (scaled like [shadow]).
  Color shadowOr(Color light, double darkAlpha) =>
      isDark ? shadow(darkAlpha) : light;

  /// centerLeft -> centerRight: #E58CFF -> #B83BF4
  LinearGradient get primaryGradient => const LinearGradient(
    colors: [EventraPalette.primaryLight, EventraPalette.primaryDeep],
  );

  /// Diagonal header gradient with the soft glow at the bottom.
  LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: headerColors,
    stops: const [0, 0.45, 0.82, 1],
  );

  /// rgba(188,71,245,0.35), blur 24, offset (0,10)
  List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: isDark ? const Color(0x40BC47F5) : const Color(0x59BC47F5),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  /// Soft shadow used by cards, chips and the nav pill.
  List<BoxShadow> get softShadow => [
    BoxShadow(
      color: shadowOr(const Color(0x1A8A4FC8), 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
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
      surfaceMuted: surfaceMuted,
      outline: outline,
      disabled: disabled,
      skeletonBase: skeletonBase,
      skeletonHighlight: skeletonHighlight,
      mapBackground: mapBackground,
      navInactive: navInactive,
      shadowTint: shadowTint,
      headerColors: headerColors,
      isDark: isDark,
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
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      outline: c(outline, other.outline),
      disabled: c(disabled, other.disabled),
      skeletonBase: c(skeletonBase, other.skeletonBase),
      skeletonHighlight: c(skeletonHighlight, other.skeletonHighlight),
      mapBackground: c(mapBackground, other.mapBackground),
      navInactive: c(navInactive, other.navInactive),
      shadowTint: c(shadowTint, other.shadowTint),
      headerColors: [
        for (var i = 0; i < headerColors.length; i++)
          c(headerColors[i], other.headerColors[i]),
      ],
      isDark: t < 0.5 ? isDark : other.isDark,
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
