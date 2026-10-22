import 'package:eventra/app/app_shell.dart';
import 'package:eventra/app/auth_guard.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/forgot_password_screen.dart';
import 'package:eventra/features/auth/presentation/login_screen.dart';
import 'package:eventra/features/auth/presentation/otp_screen.dart';
import 'package:eventra/features/auth/presentation/signup_screen.dart';
import 'package:eventra/features/design_system/presentation/design_system_screen.dart';
import 'package:eventra/features/event_details/presentation/event_details_screen.dart';
import 'package:eventra/features/explore/presentation/explore_screen.dart';
import 'package:eventra/features/favorites/presentation/favorites_screen.dart';
import 'package:eventra/features/home/presentation/all_events_screen.dart';
import 'package:eventra/features/home/presentation/home_screen.dart';
import 'package:eventra/features/notifications/presentation/notifications_screen.dart';
import 'package:eventra/features/onboarding/presentation/interests_screen.dart';
import 'package:eventra/features/onboarding/presentation/location_setup_screen.dart';
import 'package:eventra/features/onboarding/presentation/onboarding_screen.dart';
import 'package:eventra/features/onboarding/presentation/splash_screen.dart';
import 'package:eventra/features/organizer/presentation/check_in_screen.dart';
import 'package:eventra/features/organizer/presentation/event_wizard_screen.dart';
import 'package:eventra/features/organizer/presentation/organizer_dashboard_screen.dart';
import 'package:eventra/features/profile/presentation/edit_profile_screen.dart';
import 'package:eventra/features/profile/presentation/profile_screen.dart';
import 'package:eventra/features/reviews/presentation/all_reviews_screen.dart';
import 'package:eventra/features/search/presentation/search_screen.dart';
import 'package:eventra/features/settings/presentation/settings_screen.dart';
import 'package:eventra/features/tickets/presentation/booking_success_screen.dart';
import 'package:eventra/features/tickets/presentation/checkout_screen.dart';
import 'package:eventra/features/tickets/presentation/my_tickets_screen.dart';
import 'package:eventra/features/tickets/presentation/ticket_detail_screen.dart';
import 'package:eventra/features/tickets/presentation/tier_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Event pages nested under each tab so the shared-element Hero flies inside
/// the tab's navigator and the nav pill hides on the pushed page.
List<RouteBase> _eventRoutes() => [
  GoRoute(
    path: 'event/:id',
    builder: (context, state) => EventDetailsScreen(
      eventId: state.pathParameters['id']!,
      heroTag: state.extra is String ? state.extra! as String : null,
    ),
    routes: [
      GoRoute(
        path: 'tickets',
        builder: (context, state) =>
            TierPickerScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: 'map',
        builder: (context, state) =>
            ExploreScreen(focusEventId: state.pathParameters['id']),
      ),
      GoRoute(
        path: 'reviews',
        builder: (context, state) =>
            AllReviewsScreen(eventId: state.pathParameters['id']!),
      ),
    ],
  ),
];

/// Fades auth and onboarding pages in place (no platform slide).
Page<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 320),
  transitionsBuilder: (context, anim, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
    child: child,
  ),
);

GoRouter buildRouter({
  required AuthState Function() readAuth,
  required bool Function() readOnboardingSeen,
  bool Function() readOrganizerMode = _off,
  String initialLocation = '/splash',
  Listenable? refresh,
}) {
  String? from(GoRouterState s) => s.uri.queryParameters['from'];
  String email(GoRouterState s) => s.uri.queryParameters['email'] ?? '';
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      auth: readAuth(),
      onboardingSeen: readOnboardingSeen(),
      organizerMode: readOrganizerMode(),
      uri: state.uri,
    ),
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, s) => _fade(s, SplashScreen(from: from(s))),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, s) => _fade(s, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, s) => _fade(s, LoginScreen(from: from(s))),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, s) => SignUpScreen(from: from(s)),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, s) => OtpScreen(email: email(s), from: from(s)),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (context, s) => ForgotPasswordScreen(initialEmail: email(s)),
      ),
      GoRoute(
        path: '/interests',
        pageBuilder: (context, s) => _fade(
          s,
          InterestsScreen(
            from: from(s),
            editing: s.uri.queryParameters['edit'] == '1',
          ),
        ),
      ),
      GoRoute(
        path: '/location-setup',
        pageBuilder: (context, s) =>
            _fade(s, LocationSetupScreen(from: from(s))),
      ),
      // Deep link from shares: https://eventra.app/event/<id>
      GoRoute(
        path: '/event/:id',
        redirect: (context, state) =>
            '/home/event/${state.pathParameters['id']}',
      ),
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      // Checkout and the success page cover the tabs (no nav pill).
      GoRoute(
        path: '/checkout/:holdId',
        builder: (context, s) =>
            CheckoutScreen(holdId: s.pathParameters['holdId']!),
      ),
      GoRoute(
        path: '/booking-success/:orderId',
        pageBuilder: (context, s) => _fade(
          s,
          BookingSuccessScreen(orderId: s.pathParameters['orderId']!),
        ),
      ),
      GoRoute(path: '/my-tickets', redirect: (context, state) => '/tickets'),
      // Organizer mode: full-screen pages over the tabs, guarded by
      // [authRedirect] (account + organizer mode on).
      GoRoute(
        path: '/organizer',
        redirect: (context, state) =>
            state.uri.path == '/organizer' ? '/organizer/dashboard' : null,
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, s) => const OrganizerDashboardScreen(),
          ),
          GoRoute(
            path: 'events/new',
            builder: (context, s) => const EventWizardScreen(),
          ),
          GoRoute(
            path: 'drafts/:draftId',
            builder: (context, s) =>
                EventWizardScreen(draftId: s.pathParameters['draftId']),
          ),
          GoRoute(
            path: 'events/:id/edit',
            builder: (context, s) =>
                EventWizardScreen(eventId: s.pathParameters['id']),
          ),
          GoRoute(
            path: 'events/:id/check-in',
            builder: (context, s) =>
                CheckInScreen(eventId: s.pathParameters['id']!),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppShell(navigationShell: shell, location: state.uri.path),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  ..._eventRoutes(),
                  GoRoute(
                    path: 'all',
                    builder: (context, state) => const AllEventsScreen(),
                  ),
                  GoRoute(
                    path: 'search',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const SearchScreen(),
                      transitionsBuilder: (context, anim, _, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
                routes: _eventRoutes(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
                routes: _eventRoutes(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tickets',
                builder: (context, state) => const MyTicketsScreen(),
                routes: [
                  ..._eventRoutes(),
                  GoRoute(
                    path: ':ticketId',
                    builder: (context, state) => TicketDetailScreen(
                      ticketId: state.pathParameters['ticketId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  ..._eventRoutes(),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'tickets',
                    redirect: (context, state) => '/tickets',
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'design-system',
                    builder: (context, state) => const DesignSystemScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

bool _off() => false;
