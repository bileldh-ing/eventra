import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _Slide {
  const _Slide(this.title, this.body, this.photo, this.icon);
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) body;
  final String photo;
  final IconData icon;
}

final _slides = [
  _Slide(
    (l) => l.onb1Title,
    (l) => l.onb1Body,
    'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=1200&q=80&fm=jpg&fit=crop',
    Icons.explore_outlined,
  ),
  _Slide(
    (l) => l.onb2Title,
    (l) => l.onb2Body,
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200&q=80&fm=jpg&fit=crop',
    Icons.bolt_rounded,
  ),
  _Slide(
    (l) => l.onb3Title,
    (l) => l.onb3Body,
    'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=1200&q=80&fm=jpg&fit=crop',
    Icons.qr_code_2_rounded,
  ),
];

/// First-launch walkthrough: three photo slides, Skip, Next / Get Started.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  bool get _last => _index == _slides.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    context.go(auth.canBrowse ? '/home' : '/auth/login');
  }

  void _next() {
    if (_last) {
      _finish();
      return;
    }
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _pages.jumpToPage(_index + 1);
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pad = MediaQuery.paddingOf(context);
    final factory = ref.watch(imageProviderFactory);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            key: const ValueKey('onboarding-pages'),
            controller: _pages,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final s = _slides[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: factory(s.photo),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => DecoratedBox(
                      decoration: BoxDecoration(gradient: t.headerGradient),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0x00000000),
                          Color(0xB31A1530),
                          Color(0xF21A1530),
                        ],
                        stops: [0, 0.3, 0.62, 1],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 28,
                    end: 28,
                    bottom: pad.bottom + 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: t.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: t.primaryGlow,
                          ),
                          child: Icon(s.icon, color: Colors.white),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          s.title(context.l10n),
                          style: context.text.heroTitle.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.body(context.l10n),
                          style: context.text.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          PositionedDirectional(
            top: pad.top + 8,
            end: 12,
            child: AnimatedOpacity(
              opacity: _last ? 0 : 1,
              duration: t.motion.fast,
              child: TextButton(
                key: const ValueKey('onboarding-skip'),
                onPressed: _last ? null : _finish,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(
                  context.l10n.onbSkip,
                  style: context.text.button.copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 28,
            end: 28,
            bottom: pad.bottom + 28,
            child: Column(
              children: [
                Semantics(
                  label: context.l10n.onbPageOf(_index + 1, _slides.length),
                  excludeSemantics: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: t.motion.medium,
                          curve: t.motion.standard,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? t.primaryLight
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientPillButton(
                  key: const ValueKey('onboarding-next'),
                  label: _last
                      ? context.l10n.onbGetStarted
                      : context.l10n.onbNext,
                  icon: _last ? null : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
