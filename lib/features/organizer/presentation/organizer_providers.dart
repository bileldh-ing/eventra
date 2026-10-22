import 'dart:async';

import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/organizer/data/organizer_repository.dart';
import 'package:eventra/features/organizer/domain/check_in.dart';
import 'package:eventra/features/organizer/domain/dashboard.dart';
import 'package:eventra/features/organizer/domain/event_draft.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;

/// Catalogue sales recorded before the app tracked them are charted up to
/// the seed date.
final kSeedSalesAsOf = DateTime(2026, 10, 21);

String organizerModeKey(String userId) => 'organizer.mode.$userId';

/// Whether the signed-in account has switched Profile to organizer mode.
/// Persisted per account; always false for guests.
class OrganizerModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    if (user == null) return false;
    return ref.read(prefsStoreProvider).getBool(organizerModeKey(user.id)) ??
        false;
  }

  Future<void> set({required bool enabled}) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    state = enabled;
    await ref
        .read(prefsStoreProvider)
        .setBool(organizerModeKey(user.id), value: enabled);
  }
}

final organizerModeProvider = NotifierProvider<OrganizerModeNotifier, bool>(
  OrganizerModeNotifier.new,
);

final organizerIdentityProvider = Provider<OrganizerIdentity?>((ref) {
  final user = ref.watch(authControllerProvider.select((s) => s.user));
  return user == null ? null : OrganizerIdentity.forUser(user);
});

/// Bumped after a publish, a draft save or a check-in.
class OrganizerRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final organizerRevisionProvider = NotifierProvider<OrganizerRevision, int>(
  OrganizerRevision.new,
);

/// The organizer's events (seeded and published), soonest first. Seeded
/// demo events get a door list so check-in can be tried right away.
final organizerEventsProvider = FutureProvider<List<Event>>((ref) async {
  final identity = ref.watch(organizerIdentityProvider);
  if (identity == null) return const [];
  final all = await ref.watch(eventsProvider.future);
  final mine = all.where((e) => e.organizer.id == identity.id).toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));
  final repo = ref.read(organizerRepositoryProvider);
  if (identity.id == kDemoOrganizerId) {
    for (final e in mine) {
      if (!e.tags.contains('organizer')) await repo.ensureGuestList(e);
    }
  }
  return mine;
});

final dashboardProvider = FutureProvider<DashboardStats>((ref) async {
  ref
    ..watch(organizerRevisionProvider)
    ..watch(ticketingRevisionProvider);
  final events = await ref.watch(organizerEventsProvider.future);
  final repo = ref.read(organizerRepositoryProvider);
  final ids = {for (final e in events) e.id};
  return computeDashboard(
    events: events,
    sales: await repo.sales(ids),
    doors: await repo.doorCounts(ids),
    now: ref.read(clockProvider)(),
    baselineAsOf: kSeedSalesAsOf,
  );
});

final organizerDraftsProvider = FutureProvider<List<EventDraft>>((ref) async {
  ref.watch(organizerRevisionProvider);
  final user = ref.watch(authControllerProvider.select((s) => s.user));
  if (user == null) return const [];
  return ref.read(organizerRepositoryProvider).drafts(user.id);
});

final FutureProviderFamily<List<Attendee>, String> attendeesProvider =
    FutureProvider.family<List<Attendee>, String>((ref, eventId) async {
      ref
        ..watch(organizerRevisionProvider)
        ..watch(ticketingRevisionProvider);
      // Seeds the demo door lists the first time the door is opened.
      await ref.watch(organizerEventsProvider.future);
      return ref.read(organizerRepositoryProvider).attendees(eventId);
    });

final checkInSyncProvider = Provider<CheckInSync>((ref) => DemoCheckInSync());

/// Number of check-ins recorded offline and not yet synced.
final pendingCheckInsProvider = FutureProvider<int>((ref) async {
  ref.watch(organizerRevisionProvider);
  return (await ref.read(organizerRepositoryProvider).pendingCheckIns()).length;
});

/// Door actions: verify, admit, give haptic feedback, then try to sync.
class CheckInController {
  CheckInController(this.ref);
  final Ref ref;

  OrganizerRepository get _repo => ref.read(organizerRepositoryProvider);

  Future<CheckInResult> scan(String code, {required String eventId}) async {
    final qr = await ref.read(qrServiceProvider.future);
    final r = await _repo.checkInCode(code, eventId: eventId, qr: qr);
    return _after(r);
  }

  Future<CheckInResult> manual(String ticketId, {required String eventId}) =>
      _repo.checkInTicket(ticketId, eventId: eventId).then(_after);

  /// A full QR payload is verified; anything else is treated as a ticket id.
  Future<CheckInResult> enter(String text, {required String eventId}) =>
      text.trim().startsWith('ETK1.')
      ? scan(text, eventId: eventId)
      : manual(text, eventId: eventId);

  Future<CheckInResult> _after(CheckInResult r) async {
    unawaited(
      r.admitted ? HapticFeedback.mediumImpact() : HapticFeedback.vibrate(),
    );
    if (r.admitted) {
      ref.read(organizerRevisionProvider.notifier).bump();
      unawaited(flush());
    }
    return r;
  }

  /// Sends queued check-ins; returns how many are still waiting.
  Future<int> flush() async {
    final pending = await _repo.pendingCheckIns();
    if (pending.isEmpty) return 0;
    try {
      final ok = await ref.read(checkInSyncProvider).push(pending);
      await _repo.markSynced(ok);
      if (ref.mounted) ref.read(organizerRevisionProvider.notifier).bump();
      return pending.length - ok.length;
    } on Object {
      return pending.length;
    }
  }
}

final checkInControllerProvider = Provider<CheckInController>(
  CheckInController.new,
);
