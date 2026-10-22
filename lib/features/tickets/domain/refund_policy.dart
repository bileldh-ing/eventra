import 'package:meta/meta.dart';

/// Eventra's refund policy: a full refund when cancelled more than 48 hours
/// before the event starts, no refund after that. Free reservations can be
/// cancelled any time before the start (it frees the spot).
abstract final class RefundPolicy {
  static const window = Duration(hours: 48);

  static const summary =
      'Full refund when you cancel more than 48 hours before the event '
      'starts. No refunds within 48 hours of the start time.';

  static RefundDecision evaluate({
    required DateTime eventStart,
    required DateTime now,
    required int paidCents,
  }) {
    if (!now.isBefore(eventStart)) {
      return const RefundDecision._(
        allowed: false,
        refundCents: 0,
        reason: 'This event has already started.',
      );
    }
    final deadline = eventStart.subtract(window);
    if (paidCents == 0) {
      return RefundDecision._(
        allowed: true,
        refundCents: 0,
        reason: 'Free reservation: cancel any time before the event.',
        deadline: eventStart,
      );
    }
    if (now.isBefore(deadline)) {
      return RefundDecision._(
        allowed: true,
        refundCents: paidCents,
        reason: 'Full refund available until 48 hours before the event.',
        deadline: deadline,
      );
    }
    return RefundDecision._(
      allowed: false,
      refundCents: 0,
      reason: 'Refunds close 48 hours before the event starts.',
      deadline: deadline,
    );
  }
}

@immutable
class RefundDecision {
  const RefundDecision._({
    required this.allowed,
    required this.refundCents,
    required this.reason,
    this.deadline,
  });

  final bool allowed;
  final int refundCents;
  final String reason;

  /// Last moment a refund is accepted (exclusive).
  final DateTime? deadline;
}
