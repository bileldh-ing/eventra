import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';
import 'package:eventra/features/tickets/domain/refund_policy.dart';
import 'package:eventra/features/tickets/domain/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Luhn and card validation', () {
    test('known valid and invalid numbers', () {
      for (final n in [
        '4242 4242 4242 4242',
        '5555555555554444',
        '378282246310005',
        '4000 0000 0000 0002',
        '6011111111111117',
      ]) {
        expect(luhnValid(n), isTrue, reason: n);
      }
      for (final n in ['4242424242424241', '1234567812345678', 'abcd', '42']) {
        expect(luhnValid(n), isFalse, reason: n);
      }
    });

    test('brand detection and formatting', () {
      expect(CardBrand.detect('4242'), CardBrand.visa);
      expect(CardBrand.detect('5555 5555'), CardBrand.mastercard);
      expect(CardBrand.detect('2221000000000009'), CardBrand.mastercard);
      expect(CardBrand.detect('3782'), CardBrand.amex);
      expect(CardBrand.detect('9999'), CardBrand.unknown);
      expect(formatCardNumber('4242424242424242'), '4242 4242 4242 4242');
      expect(formatCardNumber('378282246310005'), '3782 822463 10005');
      expect(formatCardNumber('42424'), '4242 4');
    });

    test('number, expiry and CVC messages', () {
      expect(validateCardNumber(''), isNotNull);
      expect(validateCardNumber('4242 4242 4242'), contains('incomplete'));
      expect(validateCardNumber('4242424242424241'), contains('not valid'));
      expect(validateCardNumber('4242424242424242'), isNull);
      final now = DateTime(2026, 10, 21);
      expect(validateExpiry('10/26', now), isNull);
      expect(validateExpiry('09/26', now), 'This card expired.');
      expect(validateExpiry('13/27', now), 'Use MM/YY.');
      expect(validateExpiry('1/27', now), 'Use MM/YY.');
      expect(validateCvc('123', CardBrand.visa), isNull);
      expect(validateCvc('12', CardBrand.visa), isNotNull);
      expect(validateCvc('1234', CardBrand.amex), isNull);
    });
  });

  group('QR tokens', () {
    final key = List<int>.generate(32, (i) => i);
    final qr = QrTokenService(key);
    final t0 = DateTime.utc(2026, 10, 21, 10, 0, 5);

    String mint(DateTime at) => qr.payload(
      ticketId: 'tkt_A',
      eventId: 'evt-1',
      holderId: 'u_demo',
      now: at,
    );

    test('signed payload verifies and carries the ids', () {
      final p = mint(t0);
      expect(p.split('.'), hasLength(6));
      final v = qr.verify(p, now: t0);
      expect(v.isValid, isTrue);
      expect(v.ticketId, 'tkt_A');
      expect(v.eventId, 'evt-1');
      expect(v.holderId, 'u_demo');
    });

    test('rotates every 30 s; previous window accepted, older rejected', () {
      final p = mint(t0);
      expect(mint(t0.add(const Duration(seconds: 20))), p); // same window
      final next = mint(t0.add(const Duration(seconds: 30)));
      expect(next, isNot(p));
      expect(
        qr.verify(p, now: t0.add(const Duration(seconds: 30))).isValid,
        isTrue,
      );
      expect(
        qr.verify(p, now: t0.add(const Duration(seconds: 60))).status,
        QrStatus.expired,
      );
      expect(
        qr.verify(next, now: t0).status,
        QrStatus.notYetValid,
      );
      expect(QrTokenService.secondsLeft(t0), 25);
    });

    test('tampering, wrong key and malformed payloads are rejected', () {
      final p = mint(t0);
      final parts = p.split('.');
      final swapped = [...parts]..[1] = 'tkt_B';
      expect(
        qr.verify(swapped.join('.'), now: t0).status,
        QrStatus.badSignature,
      );
      final otherHolder = [...parts]..[3] = 'u_evil';
      expect(
        qr.verify(otherHolder.join('.'), now: t0).status,
        QrStatus.badSignature,
      );
      final otherKey = QrTokenService(List<int>.filled(32, 7));
      expect(otherKey.verify(p, now: t0).status, QrStatus.badSignature);
      expect(qr.verify('hello', now: t0).status, QrStatus.malformed);
      expect(qr.verify('ETK1.a.b.c.x.sig', now: t0).status, QrStatus.malformed);
      expect(() => QrTokenService([1, 2, 3]), throwsArgumentError);
      expect(
        () => qr.payload(ticketId: 'a.b', eventId: 'e', holderId: 'u', now: t0),
        throwsArgumentError,
      );
    });

    test('per-event secrets differ', () {
      expect(qr.eventSecret('evt-1'), isNot(qr.eventSecret('evt-2')));
    });
  });

  group('RefundPolicy', () {
    final start = DateTime(2026, 12, 1, 20);

    test('full refund more than 48 h before', () {
      final d = RefundPolicy.evaluate(
        eventStart: start,
        now: start.subtract(const Duration(hours: 48, minutes: 1)),
        paidCents: 9000,
      );
      expect(d.allowed, isTrue);
      expect(d.refundCents, 9000);
      expect(d.deadline, start.subtract(const Duration(hours: 48)));
    });

    test('no refund at or within 48 h, nor after the start', () {
      for (final now in [
        start.subtract(const Duration(hours: 48)),
        start.subtract(const Duration(hours: 2)),
        start,
        start.add(const Duration(days: 1)),
      ]) {
        final d = RefundPolicy.evaluate(
          eventStart: start,
          now: now,
          paidCents: 9000,
        );
        expect(d.allowed, isFalse, reason: '$now');
        expect(d.refundCents, 0);
      }
    });

    test('free reservations cancel any time before the start', () {
      final d = RefundPolicy.evaluate(
        eventStart: start,
        now: start.subtract(const Duration(hours: 1)),
        paidCents: 0,
      );
      expect(d.allowed, isTrue);
      expect(d.refundCents, 0);
    });
  });

  group('reminder times', () {
    final start = DateTime(2026, 12, 1, 20);
    test('24 h and 2 h before, skipping the past', () {
      expect(reminderTimes(start, DateTime(2026, 11)), [
        DateTime(2026, 11, 30, 20),
        DateTime(2026, 12, 1, 18),
      ]);
      expect(reminderTimes(start, DateTime(2026, 12, 1, 9)), [
        DateTime(2026, 12, 1, 18),
      ]);
      expect(reminderTimes(start, DateTime(2026, 12, 1, 19)), isEmpty);
    });

    test('ids are stable, distinct per slot and fit 31 bits', () {
      final a0 = reminderId('ord_1', 0);
      expect(reminderId('ord_1', 0), a0);
      expect(reminderId('ord_1', 1), isNot(a0));
      expect(reminderId('ord_2', 0), isNot(a0));
      expect(a0, lessThan(1 << 31));
    });
  });
}
