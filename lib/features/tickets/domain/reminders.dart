import 'package:eventra/l10n/l10n.dart';
import 'package:eventra/core/utils/app_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Lead times for event reminders.
const kReminderOffsets = [Duration(hours: 24), Duration(hours: 2)];

/// Reminder fire times for an event starting at [start], skipping any that
/// are already in the past at [now].
List<DateTime> reminderTimes(DateTime start, DateTime now) => [
  for (final o in kReminderOffsets)
    if (start.subtract(o).isAfter(now)) start.subtract(o),
];

/// Stable notification id for (order, slot): FNV-1a of the order id with
/// the slot in the lowest bits; fits a 31-bit int.
int reminderId(String orderId, int slot) {
  var h = 0x811c9dc5;
  for (final c in orderId.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return ((h & 0x0fffffff) << 2) | slot;
}

@immutable
class ReminderRequest {
  const ReminderRequest({
    required this.orderId,
    required this.ticketId,
    required this.eventTitle,
    required this.venue,
    required this.start,
  });

  final String orderId;

  /// Opened when the reminder is tapped.
  final String ticketId;
  final String eventTitle;
  final String venue;
  final DateTime start;
}

/// Schedules local reminders 24 h and 2 h before an event. Abstracted so
/// tests use an in-memory double.
abstract interface class ReminderScheduler {
  /// Returns the times actually scheduled.
  Future<List<DateTime>> schedule(ReminderRequest request, {DateTime? now});
  Future<void> cancel(String orderId);
}

/// flutter_local_notifications + timezone. Times are scheduled as absolute
/// instants (UTC), so they fire at the right moment whatever the device
/// zone is. Failures (no plugin, permission denied) never break checkout.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    this.onOpenTicket,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Called with the ticket id when a reminder is tapped.
  void Function(String ticketId)? onOpenTicket;
  Future<bool>? _ready;

  Future<bool> _init() => _ready ??= () async {
    try {
      tzdata.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (r) {
          final id = r.payload;
          if (id != null && id.isNotEmpty) onOpenTicket?.call(id);
        },
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return true;
    } on Object catch (e) {
      logWarning('Reminders unavailable', e);
      return false;
    }
  }();

  @override
  Future<List<DateTime>> schedule(
    ReminderRequest request, {
    DateTime? now,
  }) async {
    final times = reminderTimes(request.start, now ?? DateTime.now());
    if (times.isEmpty || !await _init()) return const [];
    final l = AppLocale.l10n;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'event_reminders',
        l.remChannel,
        channelDescription: l.remChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    final done = <DateTime>[];
    for (final at in times) {
      final slot = kReminderOffsets.indexOf(request.start.difference(at));
      try {
        await _plugin.zonedSchedule(
          id: reminderId(request.orderId, slot),
          scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          // Text is fixed at scheduling time in the language active then.
          title: slot == 0
              ? l.remTitleTomorrow(request.eventTitle)
              : l.remTitleSoon(request.eventTitle),
          body: l.remBody(request.venue),
          payload: request.ticketId,
        );
        done.add(at);
      } on Object catch (e) {
        logWarning('Could not schedule reminder', e);
      }
    }
    return done;
  }

  @override
  Future<void> cancel(String orderId) async {
    if (!await _init()) return;
    for (var slot = 0; slot < kReminderOffsets.length; slot++) {
      try {
        await _plugin.cancel(id: reminderId(orderId, slot));
      } on Object catch (e) {
        logWarning('Could not cancel reminder', e);
      }
    }
  }
}
