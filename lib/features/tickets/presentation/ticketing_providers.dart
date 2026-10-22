import 'package:eventra/core/crypto/pbkdf2.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/device_services.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';
import 'package:eventra/features/tickets/domain/reminders.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/domain/tier_rules.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;

final paymentGatewayProvider = Provider<PaymentGateway>(
  (ref) => MockPaymentGateway(),
);

/// Id generator for holds, orders and tickets (deterministic in tests).
final ticketingIdsProvider = Provider<String Function(String prefix)>(
  (ref) => TicketingRepository.newId,
);

final ticketingRepositoryProvider = Provider<TicketingRepository>(
  (ref) => TicketingRepository(
    db: ref.watch(appDatabaseProvider),
    gateway: ref.watch(paymentGatewayProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(ticketingIdsProvider),
  ),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => LocalReminderScheduler(),
);

final brightnessControllerProvider = Provider<BrightnessController>(
  (ref) => const ScreenBrightnessController(),
);

final calendarServiceProvider = Provider<CalendarService>(
  (ref) => const DeviceCalendarService(),
);

final shareServiceProvider = Provider<ShareService>(
  (ref) => const SystemShareService(),
);

const kQrKeyStorageKey = 'eventra.qr_master_key';

/// Device-local QR signing key, created once and kept in secure storage so
/// tickets render (and verify) without a network connection.
final qrServiceProvider = FutureProvider<QrTokenService>((ref) async {
  final store = ref.watch(secureStoreProvider);
  var raw = await store.read(kQrKeyStorageKey);
  if (raw == null) {
    raw = base64UrlNoPad(secureRandomBytes(32));
    await store.write(kQrKeyStorageKey, raw);
  }
  return QrTokenService(decodeBase64UrlNoPad(raw));
});

/// Bumped after every stock or order change so ticket views reload.
class TicketingRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final ticketingRevisionProvider = NotifierProvider<TicketingRevision, int>(
  TicketingRevision.new,
);

final FutureProviderFamily<List<TierAvailability>, String>
tierAvailabilityProvider =
    FutureProvider.family<List<TierAvailability>, String>(
      (ref, eventId) async {
        ref.watch(ticketingRevisionProvider);
        final event = await ref.watch(eventByIdProvider(eventId).future);
        return ref.read(ticketingRepositoryProvider).availability(event);
      },
    );

final FutureProviderFamily<TicketHold?, String> holdProvider =
    FutureProvider.family<TicketHold?, String>((ref, id) {
      ref.watch(ticketingRevisionProvider);
      return ref.read(ticketingRepositoryProvider).hold(id);
    });

/// The signed-in user's tickets, newest order first.
final myTicketsProvider = FutureProvider<List<TicketEntry>>((ref) async {
  ref.watch(ticketingRevisionProvider);
  final user = ref.watch(authControllerProvider.select((s) => s.user));
  if (user == null) return const [];
  return ref.read(ticketingRepositoryProvider).ticketsFor(user.id);
});

final FutureProviderFamily<TicketEntry?, String> ticketEntryProvider =
    FutureProvider.family<TicketEntry?, String>((ref, id) async {
      ref.watch(ticketingRevisionProvider);
      final user = ref.watch(authControllerProvider.select((s) => s.user));
      if (user == null) return null;
      return ref
          .read(ticketingRepositoryProvider)
          .ticketEntry(id, userId: user.id);
    });

final FutureProviderFamily<Order?, String> orderProvider =
    FutureProvider.family<Order?, String>((ref, id) async {
      ref.watch(ticketingRevisionProvider);
      final user = ref.watch(authControllerProvider.select((s) => s.user));
      final order = await ref.read(ticketingRepositoryProvider).orderById(id);
      return order != null && order.userId == user?.id ? order : null;
    });

/// Ticketing commands used by the screens. Each one refreshes the ticket
/// views, and orders schedule (refunds cancel) their reminders.
class TicketingActions {
  TicketingActions(this._ref);
  final Ref _ref;

  TicketingRepository get _repo => _ref.read(ticketingRepositoryProvider);
  void _bump() => _ref.read(ticketingRevisionProvider.notifier).bump();

  Future<Result<TicketHold>> hold({
    required String userId,
    required Event event,
    required Map<String, int> quantities,
  }) async {
    final r = await _repo.createHold(
      userId: userId,
      event: event,
      quantities: quantities,
    );
    _bump();
    return r;
  }

  Future<void> release(String holdId) async {
    await _repo.releaseHold(holdId);
    _bump();
  }

  Future<Result<Order>> pay(CheckoutRequest request) async {
    final r = await _repo.placeOrder(request);
    if (r case Success(value: final order)) {
      _bump();
      if (order.tickets.isNotEmpty) {
        await _ref
            .read(reminderSchedulerProvider)
            .schedule(
              ReminderRequest(
                orderId: order.id,
                ticketId: order.tickets.first.id,
                eventTitle: order.event.title,
                venue: order.event.venue,
                start: order.event.startAt,
              ),
              now: _ref.read(clockProvider)(),
            );
      }
    }
    return r;
  }

  Future<Result<Order>> refund(String orderId, {required String userId}) async {
    final r = await _repo.refundOrder(orderId, userId: userId);
    if (r.isSuccess) {
      _bump();
      await _ref.read(reminderSchedulerProvider).cancel(orderId);
    }
    return r;
  }
}

final ticketingActionsProvider = Provider<TicketingActions>(
  TicketingActions.new,
);
