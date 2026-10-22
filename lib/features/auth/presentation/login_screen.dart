import 'dart:async';

import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/auth_navigation.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 'authWelcomeBack': email + password, forgot password, demo account, guest
/// mode, 5-strike lockout with a live countdown and a shake on errors.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.from});

  /// The guarded page to return to after logging in.
  final String? from;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _shake = GlobalKey<ShakeState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;
  Duration? _locked;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startLockout(Duration left) {
    setState(() => _locked = left);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      final remaining = ref
          .read(authRepositoryProvider)
          .lockoutRemaining(_email.text);
      setState(() {
        _locked = remaining;
        if (remaining == null) {
          _error = null;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _run(Future<Result<AppUser>> Function() call) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await call();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Success():
        goAfterSignIn(context, ref, widget.from);
      case Failure(:final failure):
        if (failure is AuthFailure &&
            failure.code == AuthErrorCode.unverified) {
          await context.push(_otpUri(_email.text));
          return;
        }
        setState(() => _error = failure.message);
        _shake.currentState?.shake();
        if (failure is AuthFailure && failure.retryAfter != null) {
          _startLockout(failure.retryAfter!);
        }
    }
  }

  String _otpUri(String email) => Uri(
    path: '/auth/otp',
    queryParameters: {'email': email.trim(), 'from': ?widget.from},
  ).toString();

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) {
      _shake.currentState?.shake();
      return;
    }
    final c = ref.read(authControllerProvider.notifier);
    _run(() => c.logIn(_email.text, _password.text));
  }

  void _demo() =>
      _run(() => ref.read(authControllerProvider.notifier).logInDemo());

  Future<void> _guest() async {
    await ref.read(authControllerProvider.notifier).continueAsGuest();
    if (mounted) goAfterSignIn(context, ref, widget.from);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final locked = _locked != null;
    return AuthScaffold(
      title: context.l10n.authWelcomeBack,
      subtitle: widget.from == null
          ? context.l10n.authLoginToBook
          : context.l10n.authLoginContinue,
      onBack: context.canPop() ? context.pop : null,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.authNewHere, style: context.text.body),
          AuthLinkButton(
            key: const ValueKey('login-signup'),
            label: context.l10n.authSignUp,
            onPressed: () => context.push(
              Uri(
                path: '/auth/signup',
                queryParameters: {'from': ?widget.from},
              ).toString(),
            ),
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
                  key: const ValueKey('login-email'),
                  controller: _email,
                  label: context.l10n.fieldEmail,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 14),
                AuthField(
                  key: const ValueKey('login-password'),
                  controller: _password,
                  label: context.l10n.fieldPassword,
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: AuthValidators.loginPassword,
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AuthLinkButton(
                    key: const ValueKey('login-forgot'),
                    label: context.l10n.authForgotPassword,
                    bold: false,
                    onPressed: () => context.push(
                      Uri(
                        path: '/auth/forgot',
                        queryParameters: {'email': _email.text.trim()},
                      ).toString(),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AuthErrorBanner(message: _error),
                GradientPillButton(
                  key: const ValueKey('login-submit'),
                  label: locked
                      ? context.l10n.authTryAgainIn(
                          _locked!.inSeconds.clamp(1, 999).toString(),
                        )
                      : _busy
                      ? context.l10n.authLoggingIn
                      : context.l10n.authLogIn,
                  icon: locked ? Icons.lock_clock_outlined : null,
                  onPressed: locked || _busy ? null : _submit,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Divider(color: context.tokens.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        context.l10n.authOr,
                        style: context.text.caption,
                      ),
                    ),
                    Expanded(child: Divider(color: context.tokens.outline)),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const ValueKey('login-demo'),
                  onPressed: _busy ? null : _demo,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(context.l10n.authTryDemo),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.primary,
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(color: t.primary.withValues(alpha: 0.4)),
                    shape: const StadiumBorder(),
                    textStyle: context.text.button.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 6),
                AuthLinkButton(
                  key: const ValueKey('login-guest'),
                  label: context.l10n.authContinueGuest,
                  bold: false,
                  onPressed: _busy ? null : _guest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
