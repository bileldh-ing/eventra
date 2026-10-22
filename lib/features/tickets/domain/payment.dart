import 'dart:async';
import 'dart:math';

import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:meta/meta.dart';

/// What the buyer pays with: a saved card (by token) or a card typed in now.
@immutable
sealed class PaymentMethod {
  const PaymentMethod();
  CardBrand get brand;
  String get last4;
}

final class SavedCardMethod extends PaymentMethod {
  const SavedCardMethod(this.card);
  final SavedCard card;
  @override
  CardBrand get brand => card.brand;
  @override
  String get last4 => card.last4;
}

/// A new card. Held in memory for this checkout only and never persisted.
final class NewCardMethod extends PaymentMethod {
  NewCardMethod({required String number, required this.expiry})
    : number = digitsOnly(number);
  final String number;
  final String expiry;
  @override
  CardBrand get brand => CardBrand.detect(number);
  @override
  String get last4 => number.substring(number.length - 4);
}

enum ChargeStatus { succeeded, declined, timeout, authenticationFailed }

@immutable
class ChargeResult {
  const ChargeResult({
    required this.status,
    required this.amountCents,
    this.reference,
    this.message,
  });

  final ChargeStatus status;
  final int amountCents;

  /// Gateway charge id (set when succeeded).
  final String? reference;
  final String? message;
  bool get succeeded => status == ChargeStatus.succeeded;
}

/// Asks the buyer to approve a 3-D Secure challenge; resolves true when
/// approved.
typedef AuthenticateCallback = Future<bool> Function(int amountCents);

/// Payment provider boundary. The default is [MockPaymentGateway]; a Stripe
/// adapter would implement the same contract.
abstract interface class PaymentGateway {
  /// Charges [amountCents]. The same [idempotencyKey] always yields the same
  /// result and never charges twice.
  Future<ChargeResult> charge({
    required String idempotencyKey,
    required int amountCents,
    required PaymentMethod method,
    required AuthenticateCallback authenticate,
  });

  Future<bool> refund({required String reference, required int amountCents});
}

/// Simulated card processor using Stripe-style test numbers:
/// - 4000 0000 0000 0002: declined
/// - 4000 0000 0000 0119: processing timeout (not charged)
/// - 4000 0000 0000 3220 and the saved Mastercard: 3-D Secure challenge
/// - any other valid card: approved
class MockPaymentGateway implements PaymentGateway {
  MockPaymentGateway({this.latency = const Duration(milliseconds: 1200)});

  final Duration latency;
  final _byKey = <String, Future<ChargeResult>>{};
  final refunds = <String, int>{};
  final _random = Random.secure();

  /// Charges that actually captured money (tests assert on this).
  int capturedCount = 0;

  static const declineNumber = '4000000000000002';
  static const timeoutNumber = '4000000000000119';
  static const threeDsNumber = '4000000000003220';

  @override
  Future<ChargeResult> charge({
    required String idempotencyKey,
    required int amountCents,
    required PaymentMethod method,
    required AuthenticateCallback authenticate,
  }) => _byKey.putIfAbsent(
    idempotencyKey,
    () => _process(amountCents, method, authenticate),
  );

  Future<ChargeResult> _process(
    int amount,
    PaymentMethod method,
    AuthenticateCallback authenticate,
  ) async {
    final behaviour = switch (method) {
      SavedCardMethod(:final card) => card.token,
      NewCardMethod(:final number) => number,
    };
    if (behaviour == threeDsNumber || behaviour.endsWith('_3ds')) {
      final approved = await authenticate(amount);
      if (!approved) {
        return ChargeResult(
          status: ChargeStatus.authenticationFailed,
          amountCents: amount,
          message: 'Card authentication was cancelled. You were not charged.',
        );
      }
    }
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (behaviour == declineNumber) {
      return ChargeResult(
        status: ChargeStatus.declined,
        amountCents: amount,
        message: 'Your card was declined. Try another card.',
      );
    }
    if (behaviour == timeoutNumber) {
      return ChargeResult(
        status: ChargeStatus.timeout,
        amountCents: amount,
        message: 'The payment timed out. You were not charged; try again.',
      );
    }
    capturedCount++;
    return ChargeResult(
      status: ChargeStatus.succeeded,
      amountCents: amount,
      reference: 'ch_${_hex(12)}',
    );
  }

  String _hex(int n) =>
      List.generate(n, (_) => _random.nextInt(16).toRadixString(16)).join();

  @override
  Future<bool> refund({
    required String reference,
    required int amountCents,
  }) async {
    refunds.putIfAbsent(reference, () => amountCents);
    return true;
  }
}
