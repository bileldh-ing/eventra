import 'package:eventra/app/app_shell.dart';
import 'package:eventra/core/widgets/themed_placeholder.dart';
import 'package:eventra/features/design_system/presentation/design_system_screen.dart';
import 'package:eventra/features/event_details/presentation/event_details_screen.dart';
import 'package:eventra/features/favorites/presentation/favorites_screen.dart';
import 'package:eventra/features/home/presentation/all_events_screen.dart';
import 'package:eventra/features/home/presentation/home_screen.dart';
import 'package:eventra/features/notifications/presentation/notifications_screen.dart';
import 'package:eventra/features/profile/presentation/profile_screen.dart';
import 'package:eventra/features/search/presentation/search_screen.dart';
import 'package:eventra/features/tickets/presentation/tickets_placeholder_screen.dart';
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
            TicketsPlaceholderScreen(eventId: state.pathParameters['id']),
      ),
    ],
  ),
];

GoRouter buildRouter({String initialLocation = '/home'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      // Deep link from shares: https://eventra.app/event/<id>
      GoRoute(
        path: '/event/:id',
        redirect: (context, state) =>
            '/home/event/${state.pathParameters['id']}',
      ),
      GoRoute(path: '/', redirect: (context, state) => '/home'),
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
                builder: (context, state) =>
                    const ThemedPlaceholder(title: 'Explore'),
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
                    builder: (context, state) =>
                        const TicketsPlaceholderScreen(),
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
