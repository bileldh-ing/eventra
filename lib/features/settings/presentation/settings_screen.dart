import 'package:eventra/core/app_info.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/profile/presentation/profile_providers.dart';
import 'package:eventra/features/profile/presentation/profile_screen.dart';
import 'package:eventra/features/settings/domain/app_settings.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Appearance, language, notifications, privacy, storage, about, account.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final user = ref.watch(authControllerProvider).user;

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: EventraText.caption.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          DecoratedBox(
            // Shadow only: the Material below paints the surface so list
            // tile ink stays visible.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.radii.listCard),
              boxShadow: t.softShadow,
            ),
            child: Material(
              color: t.surface,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(t.radii.listCard),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );

    Widget toggle(
      String key,
      String title,
      String subtitle, {
      required bool value,
      required ValueChanged<bool> onChanged,
    }) => SwitchListTile.adaptive(
      key: ValueKey('setting-$key'),
      title: Text(
        title,
        style: EventraText.body.copyWith(color: t.textPrimary),
      ),
      subtitle: Text(subtitle, style: EventraText.caption),
      value: value,
      activeTrackColor: t.primary,
      onChanged: onChanged,
    );

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: const Text('Settings', style: EventraText.sectionTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          section('APPEARANCE', [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  key: const ValueKey('setting-theme'),
                  segments: [
                    for (final m in ThemeMode.values)
                      ButtonSegment(
                        value: m,
                        label: Text(
                          themeModeLabel(m),
                          key: ValueKey('theme-${m.name}'),
                        ),
                      ),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) => c.setThemeMode(v.first),
                ),
              ),
            ),
          ]),
          section('LANGUAGE', [
            for (final l in AppLanguage.values)
              ListTile(
                key: ValueKey('language-${l.name}'),
                title: Text(
                  l.label,
                  style: EventraText.body.copyWith(color: t.textPrimary),
                ),
                trailing: Text(l.code, style: EventraText.caption),
                leading: Icon(
                  s.language == l
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: s.language == l ? t.primary : t.textHint,
                ),
                selected: s.language == l,
                onTap: () => c.setLanguage(l),
              ),
          ]),
          section('NOTIFICATIONS', [
            toggle(
              'reminders',
              'Event reminders',
              '24 hours and 2 hours before events you have tickets for',
              value: s.eventReminders,
              onChanged: (v) async {
                await c.setEventReminders(value: v);
                if (user != null) {
                  await ref
                      .read(ticketingActionsProvider)
                      .applyReminderSetting(userId: user.id, enabled: v);
                }
              },
            ),
            toggle(
              'orders',
              'Order updates',
              'Booking confirmations and refunds in your inbox',
              value: s.orderUpdates,
              onChanged: (v) => c.setOrderUpdates(value: v),
            ),
            toggle(
              'recommendations',
              'Recommendations',
              'New events and price drops you might like',
              value: s.recommendations,
              onChanged: (v) => c.setRecommendations(value: v),
            ),
          ]),
          section('PRIVACY', [
            toggle(
              'personalized',
              'Personalized feed',
              'Use your interests to rank events',
              value: s.personalizedFeed,
              onChanged: (v) => c.setPersonalizedFeed(value: v),
            ),
          ]),
          section('STORAGE', [
            ListTile(
              key: const ValueKey('setting-clear-cache'),
              leading: Icon(Icons.cleaning_services_outlined, color: t.primary),
              title: Text(
                'Clear cache',
                style: EventraText.body.copyWith(color: t.textPrimary),
              ),
              subtitle: const Text(
                'Cached images and recent searches',
                style: EventraText.caption,
              ),
              onTap: () async {
                await ref.read(profileActionsProvider).clearCache();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
              },
            ),
          ]),
          section('ABOUT', [
            ListTile(
              key: const ValueKey('setting-about'),
              leading: Icon(Icons.info_outline_rounded, color: t.primary),
              title: Text(
                'About Eventra',
                style: EventraText.body.copyWith(color: t.textPrimary),
              ),
              trailing: const Text(
                'v$kAppVersion ($kAppBuild)',
                key: ValueKey('app-version'),
                style: EventraText.caption,
              ),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Eventra',
                applicationVersion: '$kAppVersion ($kAppBuild)',
                applicationLegalese: 'Discover. Book. Feel the moment.',
              ),
            ),
          ]),
          if (user != null)
            section('ACCOUNT', [
              ListTile(
                key: const ValueKey('setting-logout'),
                leading: Icon(Icons.logout_rounded, color: t.primary),
                title: Text(
                  'Log out',
                  style: EventraText.body.copyWith(color: t.textPrimary),
                ),
                onTap: () => confirmLogOut(context, ref),
              ),
              ListTile(
                key: const ValueKey('setting-delete-account'),
                leading: Icon(Icons.delete_forever_outlined, color: t.error),
                title: Text(
                  'Delete account',
                  style: EventraText.body.copyWith(color: t.error),
                ),
                onTap: () => _confirmDelete(context, ref),
              ),
            ]),
        ],
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => const _DeleteAccountDialog(),
  );
  if (!(ok ?? false)) return;
  await ref.read(profileActionsProvider).deleteAccount();
}

/// Requires typing DELETE so the account is never removed by accident.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _text.text.trim().toUpperCase() == 'DELETE';
    return AlertDialog(
      title: const Text('Delete your account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your profile, tickets, reviews and notifications are removed '
            'from this device. Tickets are not refunded. This cannot be '
            'undone.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('delete-confirm-text'),
            controller: _text,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Type DELETE'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const ValueKey('delete-account-confirm'),
          onPressed: ready ? () => Navigator.pop(context, true) : null,
          child: Text(
            'Delete',
            style: TextStyle(color: ready ? context.tokens.error : null),
          ),
        ),
      ],
    );
  }
}
