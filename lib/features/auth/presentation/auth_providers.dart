import 'dart:async';

import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/auth/data/local_auth_repository.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/domain/auth_repository.dart';
import 'package:eventra/features/auth/domain/password_hasher.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/onboarding/domain/interest.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordHasherProvider = Provider<PasswordHasher>(
  (ref) => const PasswordHasher(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => LocalAuthRepository(
    db: ref.watch(appDatabaseProvider),
    secureStore: ref.watch(secureStoreProvider),
    hasher: ref.watch(passwordHasherProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Initial auth state. Null in the app (the splash restores the session);
/// tests start already signed in or as a guest.
final authBootstrapProvider = Provider<AuthState?>((ref) => null);

const _guestKey = 'auth.guest';

/// Who is using the app. Every auth action goes through here so the router
/// guard and per-user data react to one source of truth.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() =>
      ref.read(authBootstrapProvider) ?? const AuthState.unknown();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Restores a stored session (splash). Never throws.
  Future<AuthState> restore() async {
    AppUser? user;
    try {
      user = await _repo.restoreSession();
    } on Object {
      user = null;
    }
    final guest = ref.read(prefsStoreProvider).getBool(_guestKey) ?? false;
    state = user != null
        ? AuthState.signedIn(user)
        : guest
        ? const AuthState.guest()
        : const AuthState.signedOut();
    return state;
  }

  Future<Result<AppUser>> logIn(String email, String password) =>
      _signedIn(_repo.logIn(email: email, password: password));

  Future<Result<AppUser>> logInDemo() async {
    final r = await _signedIn(_repo.logInDemo());
    if (r case Success(:final value)) unawaited(_seedDemoHistory(value));
    return r;
  }

  /// Gives the demo account a ticket to an event that already ended, so
  /// reviews can be tried right away. Best effort.
  Future<void> _seedDemoHistory(AppUser user) async {
    try {
      final now = ref.read(clockProvider)();
      final events = await ref.read(eventsProvider.future);
      final past = events.where((e) => !e.endAt.isAfter(now)).toList()
        ..sort((a, b) => b.endAt.compareTo(a.endAt));
      if (past.isEmpty) return;
      await ref
          .read(ticketingRepositoryProvider)
          .ensureDemoPastOrder(
            userId: user.id,
            attendeeName: user.name,
            attendeeEmail: user.email,
            event: past.first,
          );
      if (ref.mounted) ref.read(ticketingRevisionProvider.notifier).bump();
    } on Object {
      // Demo extras never block signing in.
    }
  }

  Future<Result<AppUser>> verifyOtp(String email, String code) =>
      _signedIn(_repo.verifyOtp(email: email, code: code));

  Future<Result<AppUser>> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _repo.signUp(name: name, email: email, password: password, phone: phone);

  Future<void> continueAsGuest() async {
    await ref.read(prefsStoreProvider).setBool(_guestKey, value: true);
    state = const AuthState.guest();
  }

  Future<void> logOut() async {
    await _repo.logOut();
    await ref.read(prefsStoreProvider).setBool(_guestKey, value: false);
    state = const AuthState.signedOut();
  }

  /// Swaps in an updated copy of the signed-in account (profile edits).
  void replaceUser(AppUser user) {
    if (state.user?.id == user.id) state = AuthState.signedIn(user);
  }

  Future<Result<AppUser>> _signedIn(Future<Result<AppUser>> call) async {
    final r = await call;
    if (r case Success(:final value)) {
      await ref.read(prefsStoreProvider).setBool(_guestKey, value: false);
      state = AuthState.signedIn(value);
    }
    return r;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

const _onboardingKey = 'onboarding.seen';

/// First-launch onboarding is shown once per device.
class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsStoreProvider).getBool(_onboardingKey) ?? false;

  Future<void> markSeen() async {
    state = true;
    await ref.read(prefsStoreProvider).setBool(_onboardingKey, value: true);
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingSeenNotifier, bool>(
  OnboardingSeenNotifier.new,
);

/// The current user's interests (guests keep their own set).
class InterestsNotifier extends Notifier<Set<Interest>> {
  String get _key =>
      'interests.${ref.read(authControllerProvider.select((s) => s.scope))}';

  @override
  Set<Interest> build() {
    ref.watch(authControllerProvider.select((s) => s.scope));
    final names = ref.read(prefsStoreProvider).getStringList(_key) ?? const [];
    return {for (final n in names) ?Interest.byName(n)};
  }

  Future<void> save(Set<Interest> interests) async {
    state = {...interests};
    await ref.read(prefsStoreProvider).setStringList(_key, [
      for (final i in Interest.values)
        if (interests.contains(i)) i.name,
    ]);
  }
}

final interestsProvider = NotifierProvider<InterestsNotifier, Set<Interest>>(
  InterestsNotifier.new,
);
