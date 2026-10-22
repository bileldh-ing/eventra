import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/organizer/domain/dashboard.dart';
import 'package:eventra/features/organizer/domain/event_draft.dart';
import 'package:eventra/features/organizer/presentation/organizer_format.dart';
import 'package:eventra/features/organizer/presentation/organizer_providers.dart';
import 'package:eventra/features/organizer/presentation/widgets/charts.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Organizer home: revenue, tickets sold, check-in rate, sales over time,
/// per-tier breakdown, drafts and upcoming events.
class OrganizerDashboardScreen extends ConsumerWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final stats = ref.watch(dashboardProvider);
    final drafts = ref.watch(organizerDraftsProvider).value ?? const [];
    final identity = ref.watch(organizerIdentityProvider);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: t.background,
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('org-create'),
        backgroundColor: t.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/organizer/events/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.orgCreateEvent),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(organizerEventsProvider);
          await ref.read(eventsProvider.notifier).refresh();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FacetedGradient(
              gradient: t.headerGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(t.radii.header),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, top + 8, 20, 28),
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('org-back'),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      color: Colors.white,
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/profile'),
                      icon: const BackButtonIcon(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.orgDashboardTitle,
                            style: context.text.heroTitle.copyWith(
                              fontSize: 28,
                            ),
                          ),
                          if (identity != null)
                            Text(
                              context.bidi(identity.name),
                              style: context.text.body.copyWith(
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            switch (stats) {
              AsyncData(:final value) => _DashboardBody(
                stats: value,
                drafts: drafts,
              ),
              AsyncError() => Padding(
                padding: const EdgeInsets.only(top: 48),
                child: MessageView.error(
                  message: context.l10n.errUnknown,
                  onRetry: () => ref.invalidate(organizerEventsProvider),
                ),
              ),
              _ => const Padding(
                padding: EdgeInsets.only(top: 96),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats, required this.drafts});
  final DashboardStats stats;
  final List<EventDraft> drafts;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final soldInWindow = stats.series.fold(0, (s, d) => s + d.tickets);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatCard(
            key: const ValueKey('stat-revenue'),
            icon: Icons.payments_outlined,
            label: l.orgRevenue,
            value: formatWholeDollars(stats.revenueCents),
            gradient: t.primaryGradient,
            large: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  key: const ValueKey('stat-sold'),
                  icon: Icons.confirmation_number_outlined,
                  label: l.orgTicketsSold,
                  value: formatCount(stats.ticketsSold),
                  footer: l.orgOfCapacity(
                    formatCount(stats.ticketsSold),
                    formatCount(stats.capacity),
                  ),
                  gradient: LinearGradient(
                    colors: [t.headerColors.first, t.headerColors.last],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  key: const ValueKey('stat-checkin'),
                  icon: Icons.qr_code_scanner_rounded,
                  label: l.orgCheckInRate,
                  value: formatPercent(stats.checkInRate),
                  footer: l.orgCheckedInOf(
                    formatCount(stats.checkedIn),
                    formatCount(stats.issued),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      t.accentOrange,
                      Color.lerp(t.accentOrange, t.primary, 0.55)!,
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Panel(
            key: const ValueKey('org-sales-chart'),
            title: l.orgSalesOverTime,
            trailing: l.orgTicketsCount(soldInWindow),
            child: SalesLineChart(
              series: stats.series,
              tokens: t,
              labelFor: formatMonthDay,
            ),
          ),
          if (stats.tiers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Panel(
              key: const ValueKey('org-tiers'),
              title: l.orgByTier,
              child: Column(
                children: [
                  for (final (i, tier) in stats.tiers.take(5).indexed) ...[
                    if (i > 0) const SizedBox(height: 14),
                    _TierRow(tier: tier),
                  ],
                ],
              ),
            ),
          ],
          if (drafts.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l.orgDrafts, style: context.text.sectionTitle),
            const SizedBox(height: 12),
            for (final d in drafts) _DraftTile(draft: d),
          ],
          const SizedBox(height: 24),
          Text(l.orgUpcoming, style: context.text.sectionTitle),
          const SizedBox(height: 12),
          if (stats.upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l.orgNoEvents,
                key: const ValueKey('org-empty'),
                style: context.text.body.copyWith(color: t.textSecondary),
              ),
            )
          else
            for (final e in stats.upcoming) _EventTile(event: e),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    super.key,
    this.footer,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? footer;
  final Gradient gradient;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(t.radii.listCard),
        boxShadow: t.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: large ? 10 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: context.text.heroTitle.copyWith(
                fontSize: large ? 34 : 26,
              ),
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 2),
            Text(
              footer!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    super.key,
    this.trailing,
  });
  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radii.listCard),
        boxShadow: t.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.text.cardTitle.copyWith(fontSize: 17),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: context.text.caption.copyWith(
                    color: t.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier});
  final TierSales tier;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.bidi(tier.name),
                style: context.text.body.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              formatWholeDollars(tier.cents),
              style: context.text.body.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FillBar(
          value: tier.fill,
          color: t.primary,
          track: t.primary.withValues(alpha: 0.12),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.orgOfCapacity(
            formatCount(tier.sold),
            formatCount(tier.capacity),
          ),
          style: context.text.caption,
        ),
      ],
    );
  }
}

class _DraftTile extends ConsumerWidget {
  const _DraftTile({required this.draft});
  final EventDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final title = draft.title.trim().isEmpty
        ? context.l10n.orgDraftUntitled
        : draft.title.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Pressable(
        key: ValueKey('draft-${draft.id}'),
        onTap: () => context.push('/organizer/drafts/${draft.id}'),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(t.radii.thumbnail),
            border: Border.all(color: t.outline),
          ),
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: t.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.bidi(title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.cardTitle.copyWith(fontSize: 16),
                    ),
                    if (draft.updatedAt != null)
                      Text(
                        context.l10n.orgDraftSavedAt(
                          formatMonthDayTime(draft.updatedAt!),
                        ),
                        style: context.text.caption,
                      ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('draft-delete-${draft.id}'),
                tooltip: context.l10n.orgDelete,
                color: t.textHint,
                onPressed: () async {
                  await ref
                      .read(organizerRepositoryProvider)
                      .deleteDraft(draft.id);
                  ref.read(organizerRevisionProvider.notifier).bump();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.orgDraftDeleted)),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final now = ref.watch(clockProvider)();
    final live = !event.startAt.isAfter(now) && event.endAt.isAfter(now);
    final (label, color) = live
        ? (l.orgStatusLive, t.success)
        : event.isSoldOut
        ? (l.orgStatusSoldOut, t.error)
        : (l.orgStatusOnSale, t.primary);
    final editable = event.tags.contains('organizer');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        key: ValueKey('org-event-${event.id}'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radii.listCard),
          boxShadow: t.softShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(t.radii.thumbnail),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: EventImage(
                      url: event.coverImageUrl,
                      category: event.category,
                      cacheWidth: 200,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.bidi(event.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.cardTitle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCardDate(event.startAt),
                        style: context.text.caption,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(t.radii.pill),
                        ),
                        child: Text(
                          label,
                          style: context.text.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: ValueKey('org-checkin-${event.id}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.primary,
                      side: BorderSide(color: t.primary.withValues(alpha: 0.4)),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () =>
                        context.push('/organizer/events/${event.id}/check-in'),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: Text(l.orgCheckIn),
                  ),
                ),
                if (editable) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: ValueKey('org-edit-${event.id}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.textPrimary,
                        side: BorderSide(color: t.outline),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () =>
                          context.push('/organizer/events/${event.id}/edit'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l.orgEdit),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
