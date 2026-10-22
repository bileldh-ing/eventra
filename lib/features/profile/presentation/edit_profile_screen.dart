import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/profile/domain/user_profile.dart';
import 'package:eventra/features/profile/presentation/profile_providers.dart';
import 'package:eventra/features/profile/presentation/widgets/initials_avatar.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Edit name, avatar color, bio and city.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final profile = ref.watch(profileProvider);
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: Text(context.l10n.editProfile, style: context.text.sectionTitle),
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(context.l10n.profileUnavailable)),
        data: (p) => p == null
            ? Center(child: Text(context.l10n.profileLoginToEdit))
            : _EditProfileForm(initial: p),
      ),
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm({required this.initial});
  final UserProfile initial;

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial.name);
  late final _bio = TextEditingController(text: widget.initial.bio);
  late final _city = TextEditingController(text: widget.initial.city);
  late int _color = widget.initial.avatarColor;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final router = GoRouter.of(context);
    try {
      await ref
          .read(profileActionsProvider)
          .save(
            UserProfile(
              name: _name.text,
              bio: _bio.text,
              city: _city.text,
              avatarColor: _color,
            ),
          );
      router.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldNotSave)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    InputDecoration deco(String label, {String? hint}) => InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: t.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 40),
        children: [
          Center(
            child: ValueListenableBuilder(
              valueListenable: _name,
              builder: (context, value, _) => InitialsAvatar(
                key: const ValueKey('edit-avatar-preview'),
                name: value.text.trim().isEmpty ? null : value.text,
                color: kAvatarColors[_color % kAvatarColors.length],
                borderWidth: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.avatarColor, style: context.text.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              for (var i = 0; i < kAvatarColors.length; i++)
                Semantics(
                  label: context.l10n.avatarColorN((i + 1).toString()),
                  selected: i == _color,
                  button: true,
                  child: GestureDetector(
                    key: ValueKey('avatar-color-$i'),
                    onTap: () => setState(() => _color = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kAvatarColors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == _color ? t.textPrimary : t.surface,
                          width: 3,
                        ),
                      ),
                      child: i == _color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('edit-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: deco(context.l10n.fieldName),
            validator: ProfileValidators.name,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('edit-city'),
            controller: _city,
            textCapitalization: TextCapitalization.words,
            decoration: deco(
              context.l10n.fieldCity,
              hint: context.l10n.fieldCityHint,
            ),
            validator: ProfileValidators.city,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('edit-bio'),
            controller: _bio,
            minLines: 2,
            maxLines: 4,
            maxLength: ProfileValidators.maxBio,
            decoration: deco(
              context.l10n.fieldBio,
              hint: context.l10n.fieldBioHint,
            ),
            validator: ProfileValidators.bio,
          ),
          const SizedBox(height: 20),
          GradientPillButton(
            key: const ValueKey('edit-save'),
            label: _saving ? context.l10n.saving : context.l10n.save,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
