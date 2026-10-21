import 'package:eventra/app/nav.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/notifications/presentation/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final items = ref.watch(notificationsProvider);
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
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: t.error.withValues(alpha: 0.12),
        child: Icon(Icons.delete_outline_rounded, color: t.error),
      ),
      onDismissed: (_) {
        final index = items.indexOf(n);
        notifier.remove(n.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Notification removed'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => notifier.insert(index, n),
              ),
            ),
          );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: t.primary.withValues(alpha: 0.12),
          child: Icon(n.kind.icon, color: t.primary),
        ),
        title: Text(
          n.title,
          style: EventraText.body.copyWith(
            color: t.textPrimary,
            fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        subtitle: Text(n.body, style: EventraText.caption),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('h:mm a').format(n.time),
              style: EventraText.caption,
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
          context.push('${currentTabRoot(context)}/event/${n.eventId}');
        },
      ),
    );

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(text, style: EventraText.cardTitle.copyWith(fontSize: 17)),
    );

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: const Text('Notifications', style: EventraText.sectionTitle),
        actions: [
          TextButton(
            key: const ValueKey('mark-all-read'),
            onPressed: items.any((n) => !n.read) ? notifier.markAllRead : null,
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: MessageView(
                icon: Icons.notifications_off_outlined,
                title: 'All caught up',
                message: 'New reminders and updates will appear here.',
                actionLabel: 'Back',
                onAction: () => Navigator.of(context).maybePop(),
              ),
            )
          : ListView(
              children: [
                if (today.isNotEmpty) ...[header('Today'), ...today.map(tile)],
                if (earlier.isNotEmpty) ...[
                  header('Earlier'),
                  ...earlier.map(tile),
                ],
              ],
            ),
    );
  }
}
