import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/notifications/presentation/notifications_providers.dart';
import 'package:eventra/features/profile/domain/user_profile.dart';
import 'package:eventra/features/profile/presentation/profile_providers.dart';
import 'package:eventra/features/profile/presentation/widgets/initials_avatar.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// Profile: the account (or guest mode) with stats, editing, settings and
/// shortcuts.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final stats = ref.watch(profileStatsProvider);
    final unread = ref.watch(unreadCountProvider);
    final top = MediaQuery.paddingOf(context).top;
    final user = ref.watch(authControllerProvider).user;
    final profile = ref.watch(profileProvider).value;

    Widget stat(String value, String label) => Expanded(
      child: Column(
        key: ValueKey('stat-$label'),
        children: [
          Text(
            value,
            style: context.text.cardTitle.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: context.text.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );

    Widget action(
      IconData icon,
      String label,
      VoidCallback onTap, {
      String? badge,
    }) => Pressable(
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
                style: context.text.cardTitle.copyWith(fontSize: 17),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: t.notificationRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: context.text.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
              padding: EdgeInsetsDirectional.fromSTEB(24, top + 24, 24, 28),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InitialsAvatar(
                        key: const ValueKey('profile-avatar'),
                        name: user?.name,
                        color: profile?.color ?? kAvatarColors.first,
                      ),
                      if (user != null)
                        PositionedDirectional(
                          end: -4,
                          bottom: -4,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              key: const ValueKey('profile-edit'),
                              tooltip: context.l10n.editProfile,
                              iconSize: 18,
                              color: t.primary,
                              onPressed: () => context.push('/profile/edit'),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? context.l10n.guest,
                    key: const ValueKey('profile-name'),
                    style: context.text.heroTitle.copyWith(fontSize: 26),
                  ),
                  Text(
                    user?.email ?? context.l10n.profileGuestPrompt,
                    style: context.text.body.copyWith(color: Colors.white),
                  ),
                  if (profile != null && profile.city.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.city,
                          key: const ValueKey('profile-city'),
                          style: context.text.caption.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (profile != null && profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.bio,
                      key: const ValueKey('profile-bio'),
                      textAlign: TextAlign.center,
                      style: context.text.body.copyWith(color: Colors.white),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      stat('${stats.tickets}', context.l10n.statTickets),
                      stat('${stats.saved}', context.l10n.statSaved),
                      stat('${stats.reviews}', context.l10n.statReviews),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 130),
            child: Column(
              children: [
                if (user == null) ...[
                  GradientPillButton(
                    key: const ValueKey('profile-login'),
                    label: context.l10n.loginOrSignup,
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
                  context.l10n.myTickets,
                  () => context.go('/tickets'),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.favorite_border_rounded,
                  context.l10n.navFavorites,
                  () => context.go('/favorites'),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.notifications_none_rounded,
                  context.l10n.notificationsTitle,
                  () => context.push('/profile/notifications'),
                  badge: unread > 0 ? '$unread' : null,
                ),
                const SizedBox(height: 12),
                action(
                  Icons.settings_outlined,
                  context.l10n.settingsTitle,
                  () => context.push('/profile/settings'),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.person_add_alt_1_outlined,
                  context.l10n.inviteFriendsTitle,
                  () => SharePlus.instance.share(
                    ShareParams(
                      text: context.l10n.inviteShareText,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                action(
                  Icons.interests_outlined,
                  context.l10n.interestsTitleShort,
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
                    context.l10n.logOut,
                    () => confirmLogOut(context, ref),
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

/// Asks before signing out (also used by Settings).
Future<void> confirmLogOut(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.logOutQ),
      content: Text(
        context.l10n.logOutBody,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          key: const ValueKey('logout-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.logOut),
        ),
      ],
    ),
  );
  if (ok ?? false) await ref.read(authControllerProvider.notifier).logOut();
}
