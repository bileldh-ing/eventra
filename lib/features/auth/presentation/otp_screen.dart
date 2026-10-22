import 'dart:async';

import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/presentation/auth_navigation.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Email confirmation: six boxes that auto-submit, a resend countdown and
/// the demo code shown in debug builds only.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.email, super.key, this.from});
  final String email;
  final String? from;

  static const resendAfter = Duration(seconds: 30);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();
  final _shake = GlobalKey<ShakeState>();
  Timer? _timer;
  int _resendIn = OtpScreen.resendAfter.inSeconds;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _resendIn = OtpScreen.resendAfter.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify([String? value]) async {
    final code = value ?? _code.text;
    if (_busy) return;
    if (code.length < 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      _shake.currentState?.shake();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(widget.email, code);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Success():
        goAfterSignIn(context, ref, widget.from);
      case Failure(:final failure):
        setState(() => _error = failure.message);
        _code.clear();
        _shake.currentState?.shake();
    }
  }

  Future<void> _resend() async {
    final r = await ref.read(authRepositoryProvider).resendOtp(widget.email);
    if (!mounted) return;
    if (r case Failure(:final failure)) {
      setState(() => _error = failure.message);
      return;
    }
    setState(_startCountdown);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('We sent a new code to ${widget.email}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AuthScaffold(
      title: 'Check your email',
      subtitle: 'Enter the 6-digit code we sent to ${widget.email}.',
      onBack: context.canPop() ? context.pop : () => context.go('/auth/login'),
      child: Shake(
        key: _shake,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OtpBoxes(
              controller: _code,
              hasError: _error != null,
              onCompleted: _verify,
            ),
            const SizedBox(height: 16),
            if (kDebugMode) ...[
              const Center(child: DemoCodeHint()),
              const SizedBox(height: 12),
            ],
            AuthErrorBanner(message: _error),
            GradientPillButton(
              key: const ValueKey('otp-submit'),
              label: _busy ? 'Verifying...' : 'Verify',
              onPressed: _busy ? null : _verify,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't get it?", style: EventraText.body),
                AuthLinkButton(
                  key: const ValueKey('otp-resend'),
                  label: _resendIn > 0
                      ? 'Resend in 0:${_resendIn.toString().padLeft(2, '0')}'
                      : 'Resend code',
                  onPressed: _resendIn > 0 ? null : _resend,
                ),
              ],
            ),
            Text(
              'Codes expire after 10 minutes.',
              textAlign: TextAlign.center,
              style: EventraText.caption.copyWith(color: t.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
