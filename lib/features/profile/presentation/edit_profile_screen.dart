import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/profile/domain/user_profile.dart';
import 'package:eventra/features/profile/presentation/profile_providers.dart';
import 'package:eventra/features/profile/presentation/widgets/initials_avatar.dart';
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
        title: const Text('Edit profile', style: EventraText.sectionTitle),
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Profile unavailable.')),
        data: (p) => p == null
            ? const Center(child: Text('Log in to edit your profile.'))
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
        ..showSnackBar(const SnackBar(content: Text('Profile updated')));
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
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
          const Text('Avatar color', style: EventraText.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              for (var i = 0; i < kAvatarColors.length; i++)
                Semantics(
                  label: 'Avatar color ${i + 1}',
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
            decoration: deco('Name'),
            validator: ProfileValidators.name,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('edit-city'),
            controller: _city,
            textCapitalization: TextCapitalization.words,
            decoration: deco('City', hint: 'Where you go out'),
            validator: ProfileValidators.city,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('edit-bio'),
            controller: _bio,
            minLines: 2,
            maxLines: 4,
            maxLength: ProfileValidators.maxBio,
            decoration: deco('Bio', hint: 'A line about you'),
            validator: ProfileValidators.bio,
          ),
          const SizedBox(height: 20),
          GradientPillButton(
            key: const ValueKey('edit-save'),
            label: _saving ? 'Saving...' : 'Save',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
