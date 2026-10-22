import 'package:eventra/app/nav_pill.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the five tab branches and the floating nav pill. The pill hides when
/// a branch shows a nested page (for example Event Details) and on the
/// full-screen Explore map.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    required this.location,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String location;

  static const tabRoots = [
    '/home',
    '/explore',
    '/favorites',
    '/tickets',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    // The Explore map is full screen (its own back button and Continue),
    // as in the reference, so the pill hides there too.
    final showPill = tabRoots.contains(location) && location != '/explore';
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          AnimatedPositionedDirectional(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            start: 24,
            end: 24,
            bottom: showPill ? 16 + bottomInset : -120,
            child: NavPill(
              currentIndex: navigationShell.currentIndex,
              onSelected: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
