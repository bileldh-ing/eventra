import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/features/organizer/domain/check_in.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Color, icon and copy for a check-in outcome.
({Color color, IconData icon, String title, String? body}) describeCheckIn(
  BuildContext context,
  CheckInResult r,
) {
  final t = context.tokens;
  final l = context.l10n;
  return switch (r.outcome) {
    CheckInOutcome.valid => (
      color: t.success,
      icon: Icons.check_circle_rounded,
      title: l.resValid,
      body: null,
    ),
    CheckInOutcome.alreadyCheckedIn => (
      color: t.accentOrange,
      icon: Icons.history_rounded,
      title: l.resAlready,
      body: r.checkedInAt == null
          ? null
          : l.resAlreadyBody(formatTime(r.checkedInAt!)),
    ),
    CheckInOutcome.wrongEvent => (
      color: t.error,
      icon: Icons.event_busy_rounded,
      title: l.resWrongEvent,
      body: l.resWrongEventBody,
    ),
    CheckInOutcome.invalid when r.reason == InvalidReason.expired => (
      color: t.error,
      icon: Icons.timer_off_rounded,
      title: l.resExpired,
      body: l.resExpiredBody,
    ),
    CheckInOutcome.invalid => (
      color: t.error,
      icon: Icons.gpp_bad_rounded,
      title: l.resForged,
      body: l.resForgedBody,
    ),
    CheckInOutcome.cancelled => (
      color: t.textSecondary,
      icon: Icons.block_rounded,
      title: l.resCancelled,
      body: l.resCancelledBody,
    ),
  };
}

/// The colored card shown after each scan: green admitted, amber already
/// used, red wrong event / invalid, gray cancelled.
class ScanResultCard extends StatelessWidget {
  const ScanResultCard({required this.result, super.key, this.onNext});

  final CheckInResult result;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final d = describeCheckIn(context, result);
    final name = result.holderName;
    return Semantics(
      liveRegion: true,
      label: d.title,
      child: Container(
        key: ValueKey('scan-result-${result.outcome.name}'),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: t.sheet,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(t.radii.sheet),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: d.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: d.color.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(d.icon, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 16),
              Text(
                d.title,
                textAlign: TextAlign.center,
                style: context.text.detailsTitle.copyWith(color: d.color),
              ),
              if (name != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.bidi(name),
                  key: const ValueKey('scan-result-name'),
                  textAlign: TextAlign.center,
                  style: context.text.cardTitle,
                ),
              ],
              if (result.tierName != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: d.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(t.radii.pill),
                  ),
                  child: Text(
                    context.bidi(result.tierName!),
                    style: context.text.caption.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (d.body != null) ...[
                const SizedBox(height: 12),
                Text(
                  d.body!,
                  textAlign: TextAlign.center,
                  style: context.text.body.copyWith(color: t.textSecondary),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  key: const ValueKey('scan-next'),
                  style: FilledButton.styleFrom(
                    backgroundColor: d.color,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onNext ?? () => Navigator.of(context).pop(),
                  child: Text(
                    context.l10n.resNextScan,
                    style: context.text.button,
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

/// Shows [ScanResultCard] as a modal sheet; completes when dismissed.
Future<void> showScanResult(BuildContext context, CheckInResult r) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ScanResultCard(result: r),
    );
