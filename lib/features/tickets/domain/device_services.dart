import 'package:add_2_calendar/add_2_calendar.dart' as cal;
import 'package:eventra/core/utils/app_log.dart';
import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';

/// Max screen brightness while a QR ticket is open (restored after).
abstract interface class BrightnessController {
  Future<void> boost();
  Future<void> restore();
}

class ScreenBrightnessController implements BrightnessController {
  const ScreenBrightnessController();

  @override
  Future<void> boost() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
    } on Object catch (e) {
      logWarning('Brightness unavailable', e);
    }
  }

  @override
  Future<void> restore() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } on Object catch (e) {
      logWarning('Brightness unavailable', e);
    }
  }
}

@immutable
class CalendarEntry {
  const CalendarEntry({
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    required this.description,
  });

  final String title;
  final DateTime start;
  final DateTime end;
  final String location;
  final String description;
}

/// Adds an event to the device calendar.
// One member, but an interface so tests can substitute a fake.
// ignore: one_member_abstracts
abstract interface class CalendarService {
  Future<bool> add(CalendarEntry entry);
}

class DeviceCalendarService implements CalendarService {
  const DeviceCalendarService();

  @override
  Future<bool> add(CalendarEntry entry) async {
    try {
      return await cal.Add2Calendar.addEvent2Cal(
        cal.Event(
          title: entry.title,
          description: entry.description,
          location: entry.location,
          startDate: entry.start,
          endDate: entry.end,
        ),
      );
    } on Object catch (e) {
      logWarning('Calendar unavailable', e);
      return false;
    }
  }
}

/// System share sheet.
// ignore: one_member_abstracts
abstract interface class ShareService {
  Future<void> share({required String text, required String subject});
}

class SystemShareService implements ShareService {
  const SystemShareService();

  @override
  Future<void> share({required String text, required String subject}) =>
      SharePlus.instance.share(ShareParams(text: text, subject: subject));
}
