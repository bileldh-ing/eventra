import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:meta/meta.dart';

/// What the door sees after a scan or a manual check-in.
enum CheckInOutcome {
  /// Admitted now.
  valid,

  /// The ticket was already used; [CheckInResult.checkedInAt] says when.
  alreadyCheckedIn,

  /// A genuine ticket, for another event.
  wrongEvent,

  /// Bad signature, unknown ticket, or a code outside its 30 s window.
  invalid,

  /// The order was refunded or the ticket cancelled.
  cancelled,
}

/// Why a code was [CheckInOutcome.invalid].
enum InvalidReason { expired, forged }

enum CheckInMethod { scan, manual }

@immutable
class CheckInResult {
  const CheckInResult(
    this.outcome, {
    this.ticketId,
    this.holderName,
    this.tierName,
    this.checkedInAt,
    this.reason,
    this.otherEventId,
  });

  final CheckInOutcome outcome;
  final String? ticketId;
  final String? holderName;
  final String? tierName;

  /// When the ticket was (first) checked in.
  final DateTime? checkedInAt;
  final InvalidReason? reason;

  /// For [CheckInOutcome.wrongEvent]: the event the ticket belongs to.
  final String? otherEventId;

  bool get admitted => outcome == CheckInOutcome.valid;
}

/// One row of the door list.
@immutable
class Attendee {
  const Attendee({
    required this.ticketId,
    required this.holderName,
    required this.tierName,
    required this.cancelled,
    this.checkedInAt,
  });
  final String ticketId;
  final String holderName;
  final String tierName;
  final bool cancelled;
  final DateTime? checkedInAt;
  bool get checkedIn => checkedInAt != null;
}

/// A check-in recorded on this device, waiting to reach the server.
@immutable
class QueuedCheckIn {
  const QueuedCheckIn({
    required this.ticketId,
    required this.eventId,
    required this.at,
    required this.method,
  });
  final String ticketId;
  final String eventId;
  final DateTime at;
  final CheckInMethod method;
}

/// Who the signed-in user publishes as.
@immutable
class OrganizerIdentity {
  const OrganizerIdentity({required this.id, required this.name});

  /// The demo account runs the seeded "Pulse Live Co." events; any other
  /// account publishes under its own name.
  factory OrganizerIdentity.forUser(AppUser user) =>
      user.email.toLowerCase() == kDemoEmail
      ? const OrganizerIdentity(id: kDemoOrganizerId, name: 'Pulse Live Co.')
      : OrganizerIdentity(id: 'org-u-${user.id}', name: user.name);

  final String id;
  final String name;

  Organizer toOrganizer() => Organizer(id: id, name: name, avatarUrl: '');
}

const kDemoOrganizerId = 'org-pulse';
