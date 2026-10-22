import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/entrance.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/onboarding/domain/interest.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 'interestsTitle': pick at least three interests (they drive the
/// smart feed). In [editing] mode (from Profile) it saves and goes back.
class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key, this.from, this.editing = false});
  final String? from;
  final bool editing;

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  late final Set<Interest> _picked = {...ref.read(interestsProvider)};

  bool get _valid => _picked.length >= Interest.minimum;

  void _toggle(Interest i) {
    HapticFeedback.selectionClick();
    setState(() => _picked.contains(i) ? _picked.remove(i) : _picked.add(i));
  }

  Future<void> _continue() async {
    await ref.read(interestsProvider.notifier).save(_picked);
    if (!mounted) return;
    if (widget.editing && context.canPop()) {
      context.pop();
      return;
    }
    context.go(
      Uri(
        path: '/location-setup',
        queryParameters: {'from': ?widget.from},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pad = MediaQuery.paddingOf(context);
    final left = Interest.minimum - _picked.length;
    return Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(24, pad.top + 16, 24, 24),
              children: [
                if (widget.editing)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: WhiteCircleButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: context.l10n.back,
                      onPressed: context.pop,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.interestsTitle,
                  style: context.text.detailsTitle.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.interestsSubtitle(Interest.minimum.toString()),
                  style: context.text.body.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    for (final (n, i) in Interest.values.indexed)
                      Entrance(
                        delay: Duration(milliseconds: 30 * n),
                        child: _InterestChip(
                          interest: i,
                          selected: _picked.contains(i),
                          onTap: () => _toggle(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, pad.bottom + 20),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: t.motion.fast,
                  child: Text(
                    _valid
                        ? context.l10n.interestsSelected(_picked.length)
                        : context.l10n.interestsChooseMore(left),
                    key: ValueKey(_picked.length),
                    style: context.text.caption,
                  ),
                ),
                const SizedBox(height: 12),
                GradientPillButton(
                  key: const ValueKey('interests-continue'),
                  label: widget.editing
                      ? context.l10n.save
                      : context.l10n.actionContinue,
                  onPressed: _valid ? _continue : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.interest,
    required this.selected,
    required this.onTap,
  });

  final Interest interest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      button: true,
      selected: selected,
      label: interest.label,
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('interest-${interest.name}'),
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.06 : 1,
          duration: reduce ? Duration.zero : const Duration(milliseconds: 520),
          curve: Curves.elasticOut,
          child: AnimatedContainer(
            duration: t.motion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: selected ? t.primaryGradient : null,
              color: selected ? null : t.surface,
              borderRadius: BorderRadius.circular(t.radii.pill),
              boxShadow: selected ? t.primaryGlow : t.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  interest.icon,
                  size: 20,
                  color: selected ? Colors.white : t.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  interest.label,
                  style: context.text.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : t.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
