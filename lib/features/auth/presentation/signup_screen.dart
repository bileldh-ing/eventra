import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Create an account: name, email, optional phone, password with a live
/// strength meter, confirmation and terms. Continues to the OTP step.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, this.from});
  final String? from;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _shake = GlobalKey<ShakeState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _terms = false;
  bool _termsError = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _form.currentState?.validate() ?? false;
    setState(() => _termsError = !_terms);
    if (!valid || !_terms) {
      _shake.currentState?.shake();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Success(:final value):
        context.pushReplacement(
          Uri(
            path: '/auth/otp',
            queryParameters: {'email': value.email, 'from': ?widget.from},
          ).toString(),
        );
      case Failure(:final failure):
        setState(() => _error = failure.message);
        _shake.currentState?.shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join Eventra to book tickets and follow organizers.',
      onBack: context.canPop() ? context.pop : null,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?', style: EventraText.body),
          AuthLinkButton(
            label: 'Log In',
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/auth/login'),
          ),
        ],
      ),
      child: Shake(
        key: _shake,
        child: Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthField(
                  key: const ValueKey('signup-name'),
                  controller: _name,
                  label: 'Full name',
                  icon: Icons.person_outline_rounded,
                  autofillHints: const [AutofillHints.name],
                  validator: AuthValidators.name,
                ),
                const SizedBox(height: 14),
                AuthField(
                  key: const ValueKey('signup-email'),
                  controller: _email,
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 14),
                AuthField(
                  key: const ValueKey('signup-phone'),
                  controller: _phone,
                  label: 'Phone (optional)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: AuthValidators.phone,
                ),
                const SizedBox(height: 14),
                AuthField(
                  key: const ValueKey('signup-password'),
                  controller: _password,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  autofillHints: const [AutofillHints.newPassword],
                  validator: AuthValidators.newPassword,
                  onChanged: (_) => setState(() {}),
                ),
                PasswordStrengthMeter(password: _password.text),
                const SizedBox(height: 14),
                AuthField(
                  key: const ValueKey('signup-confirm'),
                  controller: _confirm,
                  label: 'Confirm password',
                  icon: Icons.lock_reset_rounded,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Checkbox(
                      key: const ValueKey('signup-terms'),
                      value: _terms,
                      activeColor: t.primary,
                      side: BorderSide(
                        color: _termsError ? t.error : t.textHint,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onChanged: (v) => setState(() {
                        _terms = v ?? false;
                        if (_terms) _termsError = false;
                      }),
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: EventraText.caption.copyWith(
                          color: _termsError ? t.error : t.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AuthErrorBanner(message: _error),
                GradientPillButton(
                  key: const ValueKey('signup-submit'),
                  label: _busy ? 'Creating account...' : 'Create Account',
                  onPressed: _busy ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
