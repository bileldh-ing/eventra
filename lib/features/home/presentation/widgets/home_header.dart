import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/entrance.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/l10n/l10n.dart';
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
    this.userName = kDemoUserName,
    this.avatarUrl = kDemoUserAvatar,
  });

  /// Signed-in user's name for the initials fallback (null for guests).
  final String? userName;

  /// Portrait URL; empty shows initials.
  final String avatarUrl;

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
        padding: EdgeInsetsDirectional.fromSTEB(24, top + 12, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  label: context.l10n.openProfile,
                  child: Pressable(
                    onTap: onAvatar,
                    child: NetAvatar(
                      key: const ValueKey('home-avatar'),
                      url: avatarUrl,
                      size: 56,
                      name: userName,
                    ),
                  ),
                ),
                const Spacer(),
                GlassCircleButton(
                  key: const ValueKey('home-bell'),
                  icon: Icons.notifications_none_rounded,
                  semanticLabel: hasUnread
                      ? context.l10n.notificationsUnread
                      : context.l10n.notificationsTitle,
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
            Entrance(
              child: Text(
                context.l10n.homeHeroTitle,
                style: context.text.heroTitle,
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
                        semanticLabel: context.l10n.filtersTitle,
                        size: 54,
                        iconSize: 24,
                        iconColor: t.textPrimary.withValues(alpha: 0.7),
                        fill: Colors.white.withValues(alpha: 0.32),
                        onPressed: onFilter,
                      ),
                      if (activeFilters > 0)
                        PositionedDirectional(
                          end: -2,
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
    final t = context.tokens;
    return Semantics(
      button: true,
      label: context.l10n.searchEvents,
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
                colors: t.isDark
                    ? [
                        t.surface.withValues(alpha: 0.78),
                        t.surface.withValues(alpha: 0.5),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.72),
                        Colors.white.withValues(alpha: 0.38),
                      ],
              ),
              child: SizedBox(
                height: 54,
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    Icon(
                      Icons.search_rounded,
                      color: t.isDark
                          ? t.textSecondary
                          : const Color(0xFF7D7392),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.searchHint,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontFamilyFallback: kFontFallback,
                        fontSize: 17,
                        color: t.isDark ? t.textHint : const Color(0xFF8A809C),
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
