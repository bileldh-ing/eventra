import 'package:eventra/app/router.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/features/tickets/domain/reminders.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      // Only sign-in status matters to the guard; profile edits that swap
      // the user object must not re-run routing mid-navigation.
      ..listenManual(
        authControllerProvider.select((s) => s.status),
        (_, _) => _refresh.value++,
      )
      ..listenManual(onboardingSeenProvider, (_, _) => _refresh.value++);
    // Tapping an event reminder opens its ticket.
    if (ref.read(reminderSchedulerProvider)
        case final LocalReminderScheduler s) {
      s.onOpenTicket = (ticketId) => _router.go('/tickets/$ticketId');
    }
  }

  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(
      settingsProvider.select((s) => s.language.locale),
    );
    // Domain messages and formatters read the same locale (see AppLocale).
    AppLocale.set(locale);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: buildEventraTheme(),
      darkTheme: buildEventraTheme(brightness: Brightness.dark),
      themeMode: ref.watch(settingsProvider.select((s) => s.themeMode)),
      routerConfig: _router,
    );
  }
}
