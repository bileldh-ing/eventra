import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavPillItem {
  const NavPillItem({
    required this.id,
    required this.icon,
    required this.label,
  });

  /// Stable id for keys and tests ('Home', 'Explore', ...); never shown.
  final String id;
  final IconData icon;
  final String label;
}

/// The five tabs with labels in the current language. In RTL the Row lays
/// them out right to left, so Home stays at the leading edge.
List<NavPillItem> navItems(AppLocalizations l) => [
  NavPillItem(id: 'Home', icon: Icons.home_outlined, label: l.navHome),
  NavPillItem(id: 'Explore', icon: Icons.explore_outlined, label: l.navExplore),
  NavPillItem(
    id: 'Favorites',
    icon: Icons.favorite_border_rounded,
    label: l.navFavorites,
  ),
  NavPillItem(
    id: 'Tickets',
    icon: Icons.confirmation_number_outlined,
    label: l.navTickets,
  ),
  NavPillItem(
    id: 'Profile',
    icon: Icons.account_circle_outlined,
    label: l.navProfile,
  ),
];

/// Floating white pill navigation (72dp, radius 36). The active item expands
/// into a gradient pill with its label; width and position animate with a
/// spring curve.
class NavPill extends StatelessWidget {
  const NavPill({
    required this.currentIndex,
    required this.onSelected,
    super.key,
    this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Defaults to [navItems] in the ambient language.
  final List<NavPillItem>? items;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final items = this.items ?? navItems(context.l10n);
    return Container(
      height: t.navPillHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radii.navPill),
        boxShadow: [
          BoxShadow(
            color: t.isDark ? t.shadow(0.2) : const Color(0x2E9A5BD6),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final activeW = c.maxWidth * 0.36;
          final inactiveW = (c.maxWidth - activeW) / (items.length - 1);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavButton(
                  item: items[i],
                  active: i == currentIndex,
                  width: i == currentIndex ? activeW : inactiveW,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelected(i);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.width,
    required this.onTap,
  });

  final NavPillItem item;
  final bool active;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const duration = Duration(milliseconds: 420);
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('nav-${item.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutQuart,
          width: width,
          decoration: BoxDecoration(
            gradient: active ? t.primaryGradient : null,
            borderRadius: BorderRadius.circular(28),
            boxShadow: active ? t.primaryGlow : null,
          ),
          child: ClipRect(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.08 : 1,
                  duration: duration,
                  curve: Curves.elasticOut,
                  child: Icon(
                    item.icon,
                    size: 28,
                    color: active ? Colors.white : t.navInactive,
                  ),
                ),
                AnimatedSize(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  child: active
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(start: 10),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: context.text.button.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
