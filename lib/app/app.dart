import 'package:eventra/app/router.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventraApp extends ConsumerStatefulWidget {
  const EventraApp({super.key, this.initialLocation = '/splash'});

  /// Tests start on a specific page; the app starts on the splash.
  final String initialLocation;

  @override
  ConsumerState<EventraApp> createState() => _EventraAppState();
}

class _EventraAppState extends ConsumerState<EventraApp> {
  /// Bumped whenever auth or the onboarding flag changes so the router
  /// re-runs its guard (e.g. log out sends you to the login page).
  final _refresh = ValueNotifier<int>(0);

  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
    readAuth: () => ref.read(authControllerProvider),
    readOnboardingSeen: () => ref.read(onboardingSeenProvider),
    refresh: _refresh,
  );

  @override
  void initState() {
    super.initState();
    ref
      ..listenManual(authControllerProvider, (_, _) => _refresh.value++)
      ..listenManual(onboardingSeenProvider, (_, _) => _refresh.value++);
  }

  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Eventra',
      debugShowCheckedModeBanner: false,
      theme: buildEventraTheme(),
      routerConfig: _router,
    );
  }
}
