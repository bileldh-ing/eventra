import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tokens carry the exact spec colors and radii', () {
    const t = EventraTokens.light;
    expect(t.primary, const Color(0xFFBC47F5));
    expect(t.background, const Color(0xFFF7F1FC));
    expect(t.sheet, const Color(0xFFF9F3FE));
    expect(t.textPrimary, const Color(0xFF1A1530));
    expect(t.notificationRed, const Color(0xFFFF3D3D));
    expect(t.primaryGradient.colors, const [
      Color(0xFFE58CFF),
      Color(0xFFB83BF4),
    ]);
    expect(t.radii.eventCard, 32);
    expect(t.radii.sheet, 36);
    expect(t.radii.header, 48);
    expect(t.navPillHeight, 72);
    expect(t.buttonHeight, 58);
  });

  test('theme registers the token extension and Urbanist', () {
    final theme = buildEventraTheme();
    expect(theme.extension<EventraTokens>(), isNotNull);
    expect(theme.textTheme.bodyMedium?.fontFamily, kFontFamily);
  });

  test('lerp interpolates colors', () {
    final mid = EventraTokens.light.lerp(
      EventraTokens.light.copyWith(primary: Colors.black),
      0.5,
    );
    expect(mid.primary, isNot(EventraTokens.light.primary));
  });

  group('dark palette', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final hi = la > lb ? la : lb;
      final lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    test('forBrightness picks the dark tokens', () {
      expect(EventraTokens.forBrightness(Brightness.dark), EventraTokens.dark);
      expect(
        EventraTokens.forBrightness(Brightness.light),
        EventraTokens.light,
      );
      expect(EventraTokens.dark.isDark, isTrue);
      expect(
        EventraTokens.dark.background,
        isNot(EventraTokens.light.background),
      );
    });

    test('text clears WCAG AA on every dark surface', () {
      const t = EventraTokens.dark;
      for (final surface in [
        t.background,
        t.sheet,
        t.surface,
        t.surfaceMuted,
      ]) {
        expect(contrast(t.textPrimary, surface), greaterThanOrEqualTo(7));
        expect(contrast(t.textSecondary, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(t.textHint, surface), greaterThanOrEqualTo(3));
        expect(contrast(t.primary, surface), greaterThanOrEqualTo(3));
      }
    });

    test('dark theme wires brightness, scaffold and Arabic fallback', () {
      final theme = buildEventraTheme(brightness: Brightness.dark);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, EventraTokens.dark.background);
      expect(theme.extension<EventraTokens>(), EventraTokens.dark);
      expect(theme.textTheme.bodyMedium?.fontFamilyFallback, kFontFallback);
      expect(
        EventraTextStyles.of(EventraTokens.dark).body.color,
        EventraTokens.dark.textSecondary,
      );
    });
  });
}
