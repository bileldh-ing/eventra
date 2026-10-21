import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationKind {
  reminder(Icons.alarm_rounded),
  priceDrop(Icons.local_offer_outlined),
  friendGoing(Icons.group_outlined),
  newEvent(Icons.auto_awesome_outlined);

  const NotificationKind(this.icon);
  final IconData icon;
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    required this.eventId,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime time;
  final String eventId;
  final bool read;

  AppNotification markRead() => AppNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    time: time,
    eventId: eventId,
    read: true,
  );
}

/// Demo inbox generated from the catalogue (Phase 8 persists it in drift).
class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    // Rebuild only when data first becomes available, so refreshing the
    // feed does not reset read state.
    ref.watch(eventsProvider.select((a) => a.hasValue));
    final events = ref.read(eventsProvider).value ?? const <Event>[];
    if (events.isEmpty) return const [];
    final now = ref.read(clockProvider)();
    Event pick(int i) => events[i % events.length];
    final music = events.where((e) => e.title == 'Pitchfork Music Night');
    final pitchfork = music.isEmpty ? pick(0) : music.first;
    return [
      AppNotification(
        id: 'n1',
        kind: NotificationKind.friendGoing,
        title: '2 friends are going',
        body: 'Sarah and Liam saved ${pitchfork.title}.',
        time: now.subtract(const Duration(minutes: 25)),
        eventId: pitchfork.id,
      ),
      AppNotification(
        id: 'n2',
        kind: NotificationKind.reminder,
        title: 'Coming up soon',
        body: '${pick(0).title} is one of the next events near you.',
        time: now.subtract(const Duration(hours: 3)),
        eventId: pick(0).id,
      ),
      AppNotification(
        id: 'n3',
        kind: NotificationKind.newEvent,
        title: 'New in Music near you',
        body: '${pick(5).title} was just announced.',
        time: now.subtract(const Duration(days: 1, hours: 2)),
        eventId: pick(5).id,
        read: true,
      ),
      AppNotification(
        id: 'n4',
        kind: NotificationKind.priceDrop,
        title: 'Early Bird price available',
        body: 'Save 20% on ${pick(9).title} while Early Bird lasts.',
        time: now.subtract(const Duration(days: 2)),
        eventId: pick(9).id,
        read: true,
      ),
    ];
  }

  void markRead(String id) =>
      state = state.map((n) => n.id == id ? n.markRead() : n).toList();

  void markAllRead() => state = [for (final n in state) n.markRead()];

  void remove(String id) => state = [
    for (final n in state)
      if (n.id != id) n,
  ];

  void insert(int index, AppNotification n) =>
      state = [...state]..insert(index.clamp(0, state.length), n);
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => !n.read).length,
);
