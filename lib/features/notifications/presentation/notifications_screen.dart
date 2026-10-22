import 'package:eventra/app/nav.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/notifications/presentation/notifications_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final items = ref.watch(visibleNotificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final now = ref.watch(clockProvider)();
    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;
    final today = items.where((n) => isToday(n.time)).toList();
    final earlier = items.where((n) => !isToday(n.time)).toList();

    Widget tile(AppNotification n) => Dismissible(
      key: ValueKey('notif-${n.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        color: t.error.withValues(alpha: 0.12),
        child: Icon(Icons.delete_outline_rounded, color: t.error),
      ),
      onDismissed: (_) {
        final index = ref.read(notificationsProvider).indexOf(n);
        notifier.remove(n.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.notifRemoved),
              action: SnackBarAction(
                label: context.l10n.undo,
                onPressed: () => notifier.insert(index, n),
              ),
            ),
          );
      },
      child: ListTile(
        key: ValueKey('notif-tile-${n.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: t.primary.withValues(alpha: 0.12),
          child: Icon(n.kind.icon, color: t.primary),
        ),
        title: Text(
          n.title,
          style: context.text.body.copyWith(
            color: t.textPrimary,
            fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        subtitle: Text(n.body, style: context.text.caption),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isToday(n.time) ? formatTime(n.time) : formatMonthDay(n.time),
              style: context.text.caption,
            ),
            if (!n.read) ...[
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: t.notificationRed,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          notifier.markRead(n.id);
          if (n.ticketId case final ticket?) {
            context.go('/tickets/$ticket');
          } else if (n.eventId case final event?) {
            context.push('${currentTabRoot(context)}/event/$event');
          }
        },
      ),
    );

    Widget header(String text) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 4),
      child: Text(text, style: context.text.cardTitle.copyWith(fontSize: 17)),
    );

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: Text(
          context.l10n.notificationsTitle,
          style: context.text.sectionTitle,
        ),
        actions: [
          TextButton(
            key: const ValueKey('mark-all-read'),
            onPressed: items.any((n) => !n.read) ? notifier.markAllRead : null,
            child: Text(context.l10n.markAllRead),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: MessageView(
                icon: Icons.notifications_off_outlined,
                title: context.l10n.notifEmptyTitle,
                message: context.l10n.notifEmptyBody,
                actionLabel: context.l10n.back,
                onAction: () => Navigator.of(context).maybePop(),
              ),
            )
          : ListView(
              children: [
                if (today.isNotEmpty) ...[
                  header(context.l10n.dateToday),
                  ...today.map(tile),
                ],
                if (earlier.isNotEmpty) ...[
                  header(context.l10n.earlier),
                  ...earlier.map(tile),
                ],
              ],
            ),
    );
  }
}
