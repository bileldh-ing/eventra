import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/features/feed/domain/smart_feed_scorer.dart';
import 'package:flutter/material.dart';

IconData reasonIcon(FeedReasonKind kind) => switch (kind) {
  FeedReasonKind.interest => Icons.favorite_border_rounded,
  FeedReasonKind.nearby => Icons.near_me_outlined,
  FeedReasonKind.trending => Icons.local_fire_department_outlined,
  FeedReasonKind.soon => Icons.schedule_rounded,
  FeedReasonKind.saved => Icons.bookmark_border_rounded,
};

/// Small tinted pills explaining why an event is recommended.
class ReasonChips extends StatelessWidget {
  const ReasonChips({required this.reasons, super.key});

  final List<FeedReason> reasons;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (reasons.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in reasons)
          Container(
            key: ValueKey('reason-${r.kind.name}'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(reasonIcon(r.kind), size: 15, color: t.primary),
                const SizedBox(width: 6),
                Text(
                  r.label,
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
