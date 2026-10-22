import 'package:eventra/core/app_info.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/profile/presentation/profile_providers.dart';
import 'package:eventra/features/profile/presentation/profile_screen.dart';
import 'package:eventra/features/settings/domain/app_settings.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/l10n/l10n.dart';
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
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: context.text.caption.copyWith(fontWeight: FontWeight.w700),
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
        style: context.text.body.copyWith(color: t.textPrimary),
      ),
      subtitle: Text(subtitle, style: context.text.caption),
      value: value,
      activeTrackColor: t.primary,
      onChanged: onChanged,
    );

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: Text(
          context.l10n.settingsTitle,
          style: context.text.sectionTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          section(context.l10n.setAppearance, [
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
          section(context.l10n.setLanguage, [
            for (final l in AppLanguage.values)
              ListTile(
                key: ValueKey('language-${l.name}'),
                title: Text(
                  l.label,
                  style: context.text.body.copyWith(color: t.textPrimary),
                ),
                trailing: Text(l.code, style: context.text.caption),
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
          section(context.l10n.setNotifications, [
            toggle(
              'reminders',
              context.l10n.setReminders,
              context.l10n.setRemindersSub,
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
              context.l10n.setOrders,
              context.l10n.setOrdersSub,
              value: s.orderUpdates,
              onChanged: (v) => c.setOrderUpdates(value: v),
            ),
            toggle(
              'recommendations',
              context.l10n.setRecs,
              context.l10n.setRecsSub,
              value: s.recommendations,
              onChanged: (v) => c.setRecommendations(value: v),
            ),
          ]),
          section(context.l10n.setPrivacy, [
            toggle(
              'personalized',
              context.l10n.setPersonalized,
              context.l10n.setPersonalizedSub,
              value: s.personalizedFeed,
              onChanged: (v) => c.setPersonalizedFeed(value: v),
            ),
          ]),
          section(context.l10n.setStorage, [
            ListTile(
              key: const ValueKey('setting-clear-cache'),
              leading: Icon(Icons.cleaning_services_outlined, color: t.primary),
              title: Text(
                context.l10n.setClearCache,
                style: context.text.body.copyWith(color: t.textPrimary),
              ),
              subtitle: Text(
                context.l10n.setClearCacheSub,
                style: context.text.caption,
              ),
              onTap: () async {
                await ref.read(profileActionsProvider).clearCache();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(context.l10n.setCacheCleared)),
                  );
              },
            ),
          ]),
          section(context.l10n.setAboutSection, [
            ListTile(
              key: const ValueKey('setting-about'),
              leading: Icon(Icons.info_outline_rounded, color: t.primary),
              title: Text(
                context.l10n.setAbout,
                style: context.text.body.copyWith(color: t.textPrimary),
              ),
              trailing: Text(
                'v$kAppVersion ($kAppBuild)',
                key: const ValueKey('app-version'),
                style: context.text.caption,
              ),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: context.l10n.appTitle,
                applicationVersion: '$kAppVersion ($kAppBuild)',
                applicationLegalese: context.l10n.appTagline,
              ),
            ),
          ]),
          if (user != null)
            section(context.l10n.setAccount, [
              ListTile(
                key: const ValueKey('setting-logout'),
                leading: Icon(Icons.logout_rounded, color: t.primary),
                title: Text(
                  context.l10n.logOut,
                  style: context.text.body.copyWith(color: t.textPrimary),
                ),
                onTap: () => confirmLogOut(context, ref),
              ),
              ListTile(
                key: const ValueKey('setting-delete-account'),
                leading: Icon(Icons.delete_forever_outlined, color: t.error),
                title: Text(
                  context.l10n.deleteAccount,
                  style: context.text.body.copyWith(color: t.error),
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
    final typed = _text.text.trim().toUpperCase();
    // The English word always works, so muscle memory survives a language
    // switch.
    final ready =
        typed == 'DELETE' ||
        typed == context.l10n.deleteConfirmWord.toUpperCase();
    return AlertDialog(
      title: Text(context.l10n.deleteAccountQ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.deleteAccountBody,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('delete-confirm-text'),
            controller: _text,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.l10n.typeToConfirm(
                context.l10n.deleteConfirmWord,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          key: const ValueKey('delete-account-confirm'),
          onPressed: ready ? () => Navigator.pop(context, true) : null,
          child: Text(
            context.l10n.delete,
            style: TextStyle(color: ready ? context.tokens.error : null),
          ),
        ),
      ],
    );
  }
}
