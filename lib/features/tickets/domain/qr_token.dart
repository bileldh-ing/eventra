import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:meta/meta.dart';

/// Rotating, signed ticket QR codes that a scanner can verify offline.
///
/// Payload: `ETK1.<ticketId>.<eventId>.<holderId>.<window>.<sig>`
/// where `window = floor(unixSeconds / 30)` and the signature is
/// base64url(HMAC-SHA256(eventSecret, "ticketId|eventId|holderId|window")).
/// The per-event secret is HMAC-SHA256(masterKey, "event:" + eventId), so a
/// scanner provisioned for one event cannot mint codes for another. A code
/// is accepted in its own window and, for clock skew, the one before; a
/// screenshot stops working within a minute.
class QrTokenService {
  QrTokenService(List<int> masterKey)
    : _master = Uint8List.fromList(masterKey) {
    if (masterKey.length < 16) {
      throw ArgumentError.value(masterKey.length, 'masterKey', 'too short');
    }
  }

  final Uint8List _master;
  static const prefix = 'ETK1';
  static const windowSeconds = 30;

  static int windowAt(DateTime t) =>
      t.millisecondsSinceEpoch ~/ 1000 ~/ windowSeconds;

  /// Seconds until the code shown at [t] rotates (1..30).
  static int secondsLeft(DateTime t) {
    final s = t.millisecondsSinceEpoch ~/ 1000;
    return windowSeconds - (s % windowSeconds);
  }

  List<int> eventSecret(String eventId) =>
      Hmac(sha256, _master).convert(utf8.encode('event:$eventId')).bytes;

  String _sign(String ticketId, String eventId, String holderId, int window) {
    final mac = Hmac(
      sha256,
      eventSecret(eventId),
    ).convert(utf8.encode('$ticketId|$eventId|$holderId|$window'));
    return base64UrlNoPad(mac.bytes);
  }

  String payload({
    required String ticketId,
    required String eventId,
    required String holderId,
    required DateTime now,
  }) {
    for (final part in [ticketId, eventId, holderId]) {
      if (part.isEmpty || part.contains('.') || part.contains('|')) {
        throw ArgumentError.value(part, 'id', 'must not contain . or |');
      }
    }
    final w = windowAt(now);
    return [
      prefix,
      ticketId,
      eventId,
      holderId,
      '$w',
      _sign(ticketId, eventId, holderId, w),
    ].join('.');
  }

  QrVerification verify(String payload, {required DateTime now}) {
    final parts = payload.split('.');
    if (parts.length != 6 || parts[0] != prefix) {
      return const QrVerification._(QrStatus.malformed);
    }
    final window = int.tryParse(parts[4]);
    if (window == null) return const QrVerification._(QrStatus.malformed);
    final expected = _sign(parts[1], parts[2], parts[3], window);
    if (!constantTimeEquals(utf8.encode(expected), utf8.encode(parts[5]))) {
      return const QrVerification._(QrStatus.badSignature);
    }
    final current = windowAt(now);
    if (window > current) {
      return const QrVerification._(QrStatus.notYetValid);
    }
    if (current - window > 1) {
      return const QrVerification._(QrStatus.expired);
    }
    return QrVerification._(
      QrStatus.valid,
      ticketId: parts[1],
      eventId: parts[2],
      holderId: parts[3],
    );
  }
}

enum QrStatus { valid, malformed, badSignature, expired, notYetValid }

@immutable
class QrVerification {
  const QrVerification._(
    this.status, {
    this.ticketId,
    this.eventId,
    this.holderId,
  });
  final QrStatus status;
  final String? ticketId;
  final String? eventId;
  final String? holderId;
  bool get isValid => status == QrStatus.valid;
}
