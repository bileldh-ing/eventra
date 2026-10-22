import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:flutter/material.dart';

/// Section title with an optional trailing text button.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 12, 0),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.sectionTitle)),
          if (actionLabel != null)
            TextButton(
              key: ValueKey('action-$title'),
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: t.textPrimary),
              child: Text(
                actionLabel!,
                style: context.text.body.copyWith(
                  color: t.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact horizontal list section ('Trending This Week', ...).
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.id,
    required this.title,
    required this.events,
    super.key,
    this.reasonFor,
  });

  final String id;
  final String title;
  final List<Event> events;
  final String? Function(Event)? reasonFor;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: ValueKey('section-$id'),
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 10),
          SizedBox(
            height: 208,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 14),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => CompactEventCard(
                event: events[i],
                heroTag: '$id-${events[i].id}',
                reason: reasonFor?.call(events[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
