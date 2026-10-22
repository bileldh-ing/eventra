import 'dart:async';

import 'package:eventra/app/auth_guard.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Brand splash: logo scales in with a glow while the stored session is
/// restored, then the router guard picks onboarding, login or [from].
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.from});
  final String? from;

  /// Shortest time the brand is on screen, so it never flashes.
  static const minimumShow = Duration(milliseconds: 1100);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    await Future.wait<Object?>([
      ref.read(authControllerProvider.notifier).restore(),
      Future<void>.delayed(SplashScreen.minimumShow),
    ]);
    if (!mounted) return;
    context.go(safeFrom(widget.from) ?? '/home');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final logo = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
    );
    final tagline = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );
    return Scaffold(
      body: FacetedGradient(
        gradient: t.headerGradient,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.6, end: 1).animate(logo),
                child: FadeTransition(
                  opacity: logo,
                  child: Container(
                    key: const ValueKey('splash-logo'),
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x88FFFFFF),
                          blurRadius: 48,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: logo,
                child: Text(
                  context.l10n.appTitle,
                  style: context.text.heroTitle.copyWith(
                    fontSize: 40,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: tagline,
                child: Text(
                  context.l10n.appTagline,
                  style: context.text.body.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
