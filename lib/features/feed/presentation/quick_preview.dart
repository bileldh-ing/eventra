import 'dart:async';
import 'dart:ui' as ui;

import 'package:eventra/app/nav.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/share_event.dart';
import 'package:eventra/features/feed/domain/smart_feed_scorer.dart';
import 'package:eventra/features/feed/presentation/feed_providers.dart';
import 'package:eventra/features/feed/presentation/reason_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Long-press preview: blurred backdrop, photo, price, reasons, Save/Share.
Future<void> showQuickPreview(
  BuildContext context,
  Event event, {
  required String heroTag,
}) {
  unawaited(HapticFeedback.mediumImpact());
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Close preview',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) => QuickPreview(
      event: event,
      onOpen: () {
        Navigator.of(dialogContext).pop();
        openEvent(context, event, heroTag: heroTag);
      },
    ),
    transitionBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 12 * anim.value,
          sigmaY: 12 * anim.value,
        ),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class QuickPreview extends ConsumerWidget {
  const QuickPreview({required this.event, required this.onOpen, super.key});

  final Event event;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final score = const SmartFeedScorer().score(
      event,
      ref.watch(feedProfileProvider),
    );
    final saved = ref.watch(isFavoriteProvider(event.id));
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          key: const ValueKey('quick-preview'),
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radii.listCard),
          clipBehavior: Clip.antiAlias,
          elevation: 12,
          shadowColor: t.primary.withValues(alpha: 0.3),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: EventImage(
                    url: event.coverImageUrl,
                    category: event.category,
                    cacheWidth: 800,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: EventraText.cardTitle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatPrice(event.price),
                            key: const ValueKey('preview-price'),
                            style: EventraText.cardTitle.copyWith(
                              color: t.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${formatCardDate(event.startAt)}  ·  '
                        '${score.distanceKm.toStringAsFixed(1)} km away',
                        style: EventraText.caption,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: EventraText.caption,
                      ),
                      if (score.reasons.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        ReasonChips(reasons: score.reasons),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _CircleAction(
                            key: const ValueKey('preview-save'),
                            icon: saved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            label: saved ? 'Saved' : 'Save',
                            onTap: () => ref
                                .read(favoritesProvider.notifier)
                                .toggle(event.id),
                          ),
                          const SizedBox(width: 10),
                          Builder(
                            builder: (ctx) => _CircleAction(
                              key: const ValueKey('preview-share'),
                              icon: Icons.ios_share_rounded,
                              label: 'Share',
                              onTap: () => shareEvent(ctx, event),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientPillButton(
                              key: const ValueKey('preview-open'),
                              label: 'View event',
                              height: 50,
                              onPressed: onOpen,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: t.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: t.primary),
        ),
      ),
    );
  }
}
