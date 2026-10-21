import 'package:eventra/app/app_shell.dart';
import 'package:eventra/core/widgets/themed_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter buildRouter({String initialLocation = '/home'}) {
  StatefulShellBranch branch(String path, String title) => StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) => ThemedPlaceholder(title: title),
      ),
    ],
  );
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppShell(navigationShell: shell, location: state.uri.path),
        branches: [
          branch('/home', 'Home'),
          branch('/explore', 'Explore'),
          branch('/favorites', 'Favorites'),
          branch('/profile', 'Profile'),
        ],
      ),
    ],
  );
}
