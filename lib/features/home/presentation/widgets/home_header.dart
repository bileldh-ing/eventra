import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/entrance.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:flutter/material.dart';

const kDemoUserAvatar = 'https://randomuser.me/api/portraits/men/32.jpg';
const kDemoUserName = 'Daniel Brooks';
const kDemoUserEmail = 'daniel.brooks@eventra.app';

/// Gradient header: avatar, bell, hero text, search pill and filter button.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.onAvatar,
    required this.onBell,
    required this.onSearch,
    required this.onFilter,
    required this.hasUnread,
    required this.activeFilters,
    super.key,
    this.parallax = 0,
  });

  final VoidCallback onAvatar;
  final VoidCallback onBell;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final bool hasUnread;
  final int activeFilters;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final top = MediaQuery.paddingOf(context).top;
    return FacetedGradient(
      gradient: t.headerGradient,
      shift: parallax,
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(t.radii.header),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, top + 12, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Open profile',
                  child: Pressable(
                    onTap: onAvatar,
                    child: const NetAvatar(
                      key: ValueKey('home-avatar'),
                      url: kDemoUserAvatar,
                      size: 56,
                      name: kDemoUserName,
                    ),
                  ),
                ),
                const Spacer(),
                GlassCircleButton(
                  key: const ValueKey('home-bell'),
                  icon: Icons.notifications_none_rounded,
                  semanticLabel: hasUnread
                      ? 'Notifications, unread'
                      : 'Notifications',
                  size: 56,
                  iconSize: 26,
                  iconColor: t.textPrimary.withValues(alpha: 0.75),
                  fill: Colors.white.withValues(alpha: 0.3),
                  badge: hasUnread,
                  onPressed: onBell,
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Entrance(
              child: Text(
                'Discover Amazing\nEvents Near You',
                style: EventraText.heroTitle,
              ),
            ),
            const SizedBox(height: 26),
            Entrance(
              delay: const Duration(milliseconds: 80),
              fromScale: 0.96,
              offset: 0,
              child: Row(
                children: [
                  Expanded(child: SearchPill(onTap: onSearch)),
                  const SizedBox(width: 12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GlassCircleButton(
                        key: const ValueKey('home-filter'),
                        icon: Icons.tune_rounded,
                        semanticLabel: 'Filters',
                        size: 54,
                        iconSize: 24,
                        iconColor: t.textPrimary.withValues(alpha: 0.7),
                        fill: Colors.white.withValues(alpha: 0.32),
                        onPressed: onFilter,
                      ),
                      if (activeFilters > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: t.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              '$activeFilters',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Light glass search pill. Shares a Hero with the Search screen field.
class SearchPill extends StatelessWidget {
  const SearchPill({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search events',
      excludeSemantics: true,
      child: Pressable(
        key: const ValueKey('home-search'),
        onTap: onTap,
        pressedScale: 0.98,
        child: Hero(
          tag: 'search-field',
          child: Material(
            type: MaterialType.transparency,
            child: Glass(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.72),
                  Colors.white.withValues(alpha: 0.38),
                ],
              ),
              child: const SizedBox(
                height: 54,
                child: Row(
                  children: [
                    SizedBox(width: 18),
                    Icon(
                      Icons.search_rounded,
                      color: Color(0xFF7D7392),
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Search',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 17,
                        color: Color(0xFF8A809C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
