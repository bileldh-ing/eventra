import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Local demo reset: email first, then the code plus a new password.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});
  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _shake = GlobalKey<ShakeState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) {
      _shake.currentState?.shake();
      return;
    }
    if (_codeSent && _code.text.length < 6) {
      setState(() => _error = context.l10n.authEnterCode);
      _shake.currentState?.shake();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    final r = _codeSent
        ? await repo.resetPassword(
            email: _email.text,
            code: _code.text,
            newPassword: _password.text,
          )
        : await repo.requestPasswordReset(_email.text);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Success() when !_codeSent:
        setState(() => _codeSent = true);
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.authPasswordUpdated),
          ),
        );
        context.canPop() ? context.pop() : context.go('/auth/login');
      case Failure(:final failure):
        setState(() => _error = failure.message);
        _shake.currentState?.shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: _codeSent
          ? context.l10n.authSetNewPassword
          : context.l10n.authForgotPassword,
      subtitle: _codeSent
          ? context.l10n.authResetCodeSent(_email.text.trim())
          : context.l10n.authResetIntro,
      onBack: context.canPop() ? context.pop : () => context.go('/auth/login'),
      child: Shake(
        key: _shake,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthField(
                key: const ValueKey('forgot-email'),
                controller: _email,
                enabled: !_codeSent,
                label: context.l10n.fieldEmail,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidators.email,
              ),
              if (_codeSent) ...[
                const SizedBox(height: 18),
                OtpBoxes(controller: _code, hasError: _error != null),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  const Center(child: DemoCodeHint()),
                ],
                const SizedBox(height: 14),
                AuthField(
                  key: const ValueKey('forgot-password'),
                  controller: _password,
                  label: context.l10n.fieldNewPassword,
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.newPassword,
                  onChanged: (_) => setState(() {}),
                ),
                PasswordStrengthMeter(password: _password.text),
              ],
              const SizedBox(height: 18),
              AuthErrorBanner(message: _error),
              GradientPillButton(
                key: const ValueKey('forgot-submit'),
                label: _busy
                    ? context.l10n.pleaseWait
                    : _codeSent
                    ? context.l10n.authUpdatePassword
                    : context.l10n.authSendResetCode,
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.authDemoNotice,
                textAlign: TextAlign.center,
                style: context.text.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
