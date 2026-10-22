import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticket_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Ticket wallet tab: Upcoming / Past / Cancelled (swipe between them).
class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  static const List<(TicketBucket, String)> _tabs = [
    (TicketBucket.upcoming, 'Upcoming'),
    (TicketBucket.past, 'Past'),
    (TicketBucket.cancelled, 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final tickets = ref.watch(myTicketsProvider);
    final now = ref.watch(clockProvider)();
    final all = tickets.value ?? const <TicketEntry>[];
    List<TicketEntry> of(TicketBucket b) {
      // Upcoming soonest first; past and cancelled most recent first.
      return all.where((e) => bucketOf(e, now) == b).toList()..sort(
        (a, c) => b == TicketBucket.upcoming
            ? a.event.startAt.compareTo(c.event.startAt)
            : c.event.startAt.compareTo(a.event.startAt),
      );
    }

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: t.background,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.paddingOf(context).top + 16,
                24,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Tickets',
                      style: EventraText.detailsTitle.copyWith(fontSize: 28),
                    ),
                  ),
                  Icon(Icons.wallet_rounded, color: t.primary, size: 28),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: t.softShadow,
              ),
              child: TabBar(
                key: const ValueKey('tickets-tabs'),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: t.primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: t.textSecondary,
                labelStyle: EventraText.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: EventraText.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  for (final (b, label) in _tabs)
                    Tab(
                      key: ValueKey('tab-${b.name}'),
                      height: 40,
                      text: tickets.hasValue
                          ? '$label (${of(b).length})'
                          : label,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: switch (tickets) {
                AsyncError() => MessageView.error(
                  message: 'We could not open your tickets.',
                  onRetry: () => ref.invalidate(myTicketsProvider),
                ),
                AsyncData() => TabBarView(
                  children: [
                    for (final (b, _) in _tabs)
                      _TicketList(bucket: b, items: of(b), now: now),
                  ],
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  const _TicketList({
    required this.bucket,
    required this.items,
    required this.now,
  });

  final TicketBucket bucket;
  final List<TicketEntry> items;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final (title, message) = switch (bucket) {
        TicketBucket.upcoming => (
          'No upcoming tickets',
          'Find something you love and your tickets will live here, '
              'ready to scan even offline.',
        ),
        TicketBucket.past => (
          'No past events yet',
          'Events you attend will be kept here.',
        ),
        TicketBucket.cancelled => (
          'Nothing cancelled',
          'Refunded tickets show up here.',
        ),
      };
      return SingleChildScrollView(
        key: ValueKey('empty-${bucket.name}'),
        child: MessageView(
          icon: Icons.confirmation_number_outlined,
          title: title,
          message: message,
          actionLabel: bucket == TicketBucket.upcoming
              ? 'Explore events'
              : null,
          onAction: bucket == TicketBucket.upcoming
              ? () => context.go('/home')
              : null,
        ),
      );
    }
    return ListView.separated(
      key: ValueKey('list-${bucket.name}'),
      // Room for the floating nav pill.
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        120 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) => WalletTicketCard(
        entry: items[i],
        now: now,
        onTap: () => context.push('/tickets/${items[i].ticket.id}'),
      ),
    );
  }
}
