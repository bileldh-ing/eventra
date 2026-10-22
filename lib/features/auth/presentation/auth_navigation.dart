import 'package:eventra/app/auth_guard.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// After signing in (or choosing guest mode): first-timers pick interests,
/// everyone else returns to the page that asked them to log in.
void goAfterSignIn(BuildContext context, WidgetRef ref, String? from) {
  final target = safeFrom(from);
  if (ref.read(interestsProvider).isEmpty) {
    context.go(
      Uri(path: '/interests', queryParameters: {'from': ?target}).toString(),
    );
    return;
  }
  // Guests cannot open account-only pages; send them Home instead.
  final auth = ref.read(authControllerProvider);
  if (target != null &&
      needsAccount(Uri.parse(target).path) &&
      !auth.isSignedIn) {
    context.go('/home');
    return;
  }
  context.go(target ?? '/home');
}
