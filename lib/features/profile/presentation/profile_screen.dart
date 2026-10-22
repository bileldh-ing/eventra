import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/home/presentation/widgets/home_header.dart';
import 'package:eventra/features/notifications/presentation/notifications_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// Profile: the signed-in account or guest mode, with Log in / Log out
/// (Phase 8 adds settings and editing).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final saved = ref.watch(favoritesProvider).length;
    final upcoming = ref.watch(upcomingEventsProvider).value?.length ?? 0;
    final unread = ref.watch(unreadCountProvider);
    final top = MediaQuery.paddingOf(context).top;
    final user = ref.watch(authControllerProvider).user;

    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: EventraText.cardTitle.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: EventraText.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );

    Widget action(IconData icon, String label, VoidCallback onTap) => Pressable(
      key: ValueKey('profile-$label'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radii.listCard),
          boxShadow: t.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: t.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: EventraText.cardTitle.copyWith(fontSize: 17),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: t.textHint),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: t.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          FacetedGradient(
            gradient: t.headerGradient,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(t.radii.header),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, top + 24, 24, 28),
              child: Column(
                children: [
                  NetAvatar(
                    key: const ValueKey('profile-avatar'),
                    // Only the demo account has a portrait; others get
                    // their initials (guests a person icon).
                    url: user?.email == kDemoEmail ? kDemoUserAvatar : '',
                    size: 96,
                    borderWidth: 3,
                    name: user?.name,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Guest',
                    key: const ValueKey('profile-name'),
                    style: EventraText.heroTitle.copyWith(fontSize: 26),
                  ),
                  Text(
                    user?.email ?? 'Log in to buy tickets and sync favorites',
                    style: EventraText.body.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      stat('$saved', 'Saved'),
                      stat('$upcoming', 'Upcoming'),
                      stat('$unread', 'Unread'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
            child: Column(
              children: [
                if (user == null) ...[
                  GradientPillButton(
                    key: const ValueKey('profile-login'),
                    label: 'Log in or sign up',
                    onPressed: () => context.push(
                      Uri(
                        path: '/auth/login',
                        queryParameters: {'from': '/profile'},
                      ).toString(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                action(
                  Icons.confirmation_number_outlined,
                  'My Tickets',
                  () => context.go('/tickets'),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.favorite_border_rounded,
                  'Favorites',
                  () => context.go('/favorites'),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.notifications_none_rounded,
                  'Notifications',
                  () => context.push('/profile/notifications'),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.person_add_alt_1_outlined,
                  'Invite Friends',
                  () => SharePlus.instance.share(
                    ShareParams(
                      text:
                          'I find events on Eventra - Discover. Book. Feel the '
                          'moment. https://eventra.app',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.interests_outlined,
                  'Interests',
                  () => context.push('/interests?edit=1'),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  action(
                    Icons.palette_outlined,
                    'Design System',
                    () => context.push('/profile/design-system'),
                  ),
                ],
                if (user != null) ...[
                  const SizedBox(height: 12),
                  action(
                    Icons.logout_rounded,
                    'Log out',
                    () => _confirmLogOut(context, ref),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmLogOut(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text(
        'Your tickets and favorites stay on this device for when you are '
        'back.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const ValueKey('logout-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
  if (ok ?? false) await ref.read(authControllerProvider.notifier).logOut();
}
