import 'package:eventra/features/tickets/domain/pricing.dart';
import 'package:meta/meta.dart';

enum HoldStatus { active, released, expired, converted }

@immutable
class HoldLine {
  const HoldLine({required this.tierId, required this.quantity});
  final String tierId;
  final int quantity;
}

/// Seats reserved for one buyer while they check out (10 minutes).
@immutable
class TicketHold {
  const TicketHold({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.lines,
  });

  final String id;
  final String userId;
  final String eventId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final HoldStatus status;
  final List<HoldLine> lines;

  int get quantity => lines.fold(0, (s, l) => s + l.quantity);
  bool isLive(DateTime now) =>
      status == HoldStatus.active && now.isBefore(expiresAt);
  Duration remaining(DateTime now) {
    final d = expiresAt.difference(now);
    return d.isNegative ? Duration.zero : d;
  }
}

enum OrderStatus { paid, refunded }

enum TicketStatus { valid, used, cancelled }

/// Event details copied onto the order so tickets open fully offline even
/// if the catalogue changes or cannot load.
@immutable
class EventSnapshot {
  const EventSnapshot({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.venue,
    required this.address,
    required this.coverImageUrl,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String venue;
  final String address;
  final String coverImageUrl;
  final double latitude;
  final double longitude;
}

@immutable
class Ticket {
  const Ticket({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.eventId,
    required this.tierId,
    required this.tierName,
    required this.holderName,
    required this.status,
    required this.seq,
  });

  final String id;
  final String orderId;
  final String userId;
  final String eventId;
  final String tierId;
  final String tierName;
  final String holderName;
  final TicketStatus status;

  /// 1-based position in its order ("Ticket 2 of 3").
  final int seq;
}

@immutable
class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.idempotencyKey,
    required this.status,
    required this.event,
    required this.lines,
    required this.subtotalCents,
    required this.discountCents,
    required this.feesCents,
    required this.taxCents,
    required this.totalCents,
    required this.refundCents,
    required this.attendeeName,
    required this.attendeeEmail,
    required this.createdAt,
    required this.tickets,
    this.promoCode,
    this.paymentRef,
    this.cardBrand,
    this.cardLast4,
    this.refundedAt,
  });

  final String id;
  final String userId;
  final String idempotencyKey;
  final OrderStatus status;
  final EventSnapshot event;
  final List<PriceLine> lines;
  final int subtotalCents;
  final int discountCents;
  final int feesCents;
  final int taxCents;
  final int totalCents;
  final int refundCents;
  final String attendeeName;
  final String attendeeEmail;
  final DateTime createdAt;
  final List<Ticket> tickets;
  final String? promoCode;
  final String? paymentRef;
  final String? cardBrand;
  final String? cardLast4;
  final DateTime? refundedAt;

  int get ticketCount => tickets.length;
  String get eventId => event.id;
}

/// A ticket with its order, which carries the event snapshot.
@immutable
class TicketEntry {
  const TicketEntry(this.ticket, this.order);
  final Ticket ticket;
  final Order order;

  EventSnapshot get event => order.event;
}

enum TicketBucket { upcoming, past, cancelled }

TicketBucket bucketOf(TicketEntry e, DateTime now) {
  if (e.ticket.status == TicketStatus.cancelled) return TicketBucket.cancelled;
  if (e.ticket.status == TicketStatus.used || !now.isBefore(e.event.endAt)) {
    return TicketBucket.past;
  }
  return TicketBucket.upcoming;
}

/// Label for the status chip on a ticket.
String ticketStatusLabel(TicketEntry e, DateTime now) =>
    switch (e.ticket.status) {
      TicketStatus.cancelled => 'Cancelled',
      TicketStatus.used => 'Used',
      TicketStatus.valid => now.isBefore(e.event.endAt) ? 'Valid' : 'Expired',
    };
