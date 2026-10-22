import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum NotificationKind {
  reminder(Icons.alarm_rounded),
  priceDrop(Icons.local_offer_outlined, recommendation: true),
  friendGoing(Icons.group_outlined),
  newEvent(Icons.auto_awesome_outlined, recommendation: true),
  orderConfirmed(Icons.confirmation_number_outlined),
  refund(Icons.currency_exchange_rounded),
  reviewPrompt(Icons.star_outline_rounded);

  const NotificationKind(this.icon, {this.recommendation = false});
  final IconData icon;

  /// Hidden when the user turns off recommendation notifications.
  final bool recommendation;

  static NotificationKind parse(String name) =>
      values.firstWhereOrNull((k) => k.name == name) ?? newEvent;
}

/// One inbox item. Tapping opens [ticketId] when set, else [eventId].
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    this.eventId,
    this.ticketId,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime time;
  final String? eventId;
  final String? ticketId;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    time: time,
    eventId: eventId,
    ticketId: ticketId,
    read: read ?? this.read,
  );

  @override
  bool operator ==(Object other) =>
      other is AppNotification &&
      other.id == id &&
      other.kind == kind &&
      other.title == title &&
      other.body == body &&
      other.time == time &&
      other.eventId == eventId &&
      other.ticketId == ticketId &&
      other.read == read;

  @override
  int get hashCode =>
      Object.hash(id, kind, title, body, time, eventId, ticketId, read);
}
