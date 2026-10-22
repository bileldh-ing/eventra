import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticket_visuals.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Ticket wallet tab: Upcoming / Past / Cancelled (swipe between them).
class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  static List<(TicketBucket, String)> _tabs(AppLocalizations l) => [
    (TicketBucket.upcoming, l.tabUpcoming),
    (TicketBucket.past, l.tabPast),
    (TicketBucket.cancelled, l.tabCancelled),
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
      length: TicketBucket.values.length,
      child: Scaffold(
        backgroundColor: t.background,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                24,
                MediaQuery.paddingOf(context).top + 16,
                24,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.myTickets,
                      style: context.text.detailsTitle.copyWith(fontSize: 28),
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
                labelStyle: context.text.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: context.text.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  for (final (b, label) in _tabs(context.l10n))
                    Tab(
                      key: ValueKey('tab-${b.name}'),
                      height: 40,
                      text: tickets.hasValue
                          ? context.l10n.tabWithCount(
                              label,
                              of(b).length.toString(),
                            )
                          : label,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: switch (tickets) {
                AsyncError() => MessageView.error(
                  message: context.l10n.mtLoadFailed,
                  onRetry: () => ref.invalidate(myTicketsProvider),
                ),
                AsyncData() => TabBarView(
                  children: [
                    for (final (b, _) in _tabs(context.l10n))
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
          context.l10n.mtNoUpcoming,
          context.l10n.mtNoUpcomingBody,
        ),
        TicketBucket.past => (
          context.l10n.mtNoPast,
          context.l10n.mtNoPastBody,
        ),
        TicketBucket.cancelled => (
          context.l10n.mtNoCancelled,
          context.l10n.mtNoCancelledBody,
        ),
      };
      return SingleChildScrollView(
        key: ValueKey('empty-${bucket.name}'),
        child: MessageView(
          icon: Icons.confirmation_number_outlined,
          title: title,
          message: message,
          actionLabel: bucket == TicketBucket.upcoming
              ? context.l10n.exploreEvents
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
      padding: EdgeInsetsDirectional.fromSTEB(
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
