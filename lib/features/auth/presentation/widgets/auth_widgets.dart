import 'dart:math' as math;

import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Auth page frame: faceted gradient header with a title, and a white
/// rounded form card that overlaps it (spec: auth layout).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.onBack,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: t.background,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            FacetedGradient(
              gradient: t.headerGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(t.radii.header),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, top + 12, 24, 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      child: onBack == null
                          ? null
                          : GlassCircleButton(
                              key: const ValueKey('auth-back'),
                              icon: Icons.arrow_back_rounded,
                              semanticLabel: 'Back',
                              onPressed: onBack,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(title, style: EventraText.heroTitle),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: EventraText.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(t.radii.sheet),
                    boxShadow: t.softShadow,
                  ),
                  child: child,
                ),
              ),
            ),
            if (footer != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// Rounded, filled text field in the house style.
class AuthField extends StatelessWidget {
  const AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    super.key,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: c, width: w),
    );
    return TextFormField(
      controller: controller,
      validator: validator,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscure,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: EventraText.body.copyWith(color: t.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: EventraText.body.copyWith(color: t.textHint),
        prefixIcon: Icon(icon, color: t.textHint),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                tooltip: obscure ? 'Show password' : 'Hide password',
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: t.textHint,
                ),
                onPressed: onToggleObscure,
              ),
        filled: true,
        fillColor: t.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: border(Colors.transparent),
        disabledBorder: border(Colors.transparent),
        focusedBorder: border(t.primary, 1.5),
        errorBorder: border(t.error),
        focusedErrorBorder: border(t.error, 1.5),
        errorStyle: EventraText.caption.copyWith(color: t.error),
      ),
    );
  }
}

/// Inline error banner shown above the submit button.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnimatedSize(
      duration: t.motion.medium,
      curve: t.motion.standard,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              key: const ValueKey('auth-error'),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: t.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        message!,
                        style: EventraText.caption.copyWith(color: t.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Horizontal shake used to flag a rejected form. Call [ShakeState.shake].
class Shake extends StatefulWidget {
  const Shake({required this.child, super.key});
  final Widget child;

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void shake() {
    HapticFeedback.mediumImpact();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) => Transform.translate(
      offset: Offset(
        math.sin(_c.value * math.pi * 6) * 10 * (1 - _c.value),
        0,
      ),
      child: child,
    ),
  );
}

/// Four animated bars plus a label that track [passwordStrength].
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({required this.password, super.key});
  final String password;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final s = passwordStrength(password);
    final color = switch (s) {
      PasswordStrength.empty => t.textHint,
      PasswordStrength.weak => t.error,
      PasswordStrength.fair => t.accentOrange,
      PasswordStrength.good => t.primary,
      PasswordStrength.strong => t.success,
    };
    return Semantics(
      label: s == PasswordStrength.empty
          ? 'Password strength'
          : 'Password strength ${s.label}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
        child: Row(
          children: [
            for (var i = 1; i <= 4; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: t.motion.medium,
                  curve: t.motion.standard,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= s.level ? color : const Color(0xFFEDE6F5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            SizedBox(
              width: 56,
              child: AnimatedSwitcher(
                duration: t.motion.fast,
                child: Text(
                  s.label,
                  key: ValueKey(s),
                  textAlign: TextAlign.end,
                  style: EventraText.caption.copyWith(color: color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Six code boxes over one hidden field, so typing auto-advances, backspace
/// steps back and a pasted code fills every box.
class OtpBoxes extends StatefulWidget {
  const OtpBoxes({
    required this.controller,
    super.key,
    this.onCompleted,
    this.hasError = false,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool autofocus;

  static const length = 6;

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focus.requestFocus,
      child: Stack(
        children: [
          // The real input: invisible but focusable, sized like the row.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                key: const ValueKey('otp-input'),
                controller: widget.controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: OtpBoxes.length,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) {
                  setState(() {});
                  if (v.length == OtpBoxes.length) widget.onCompleted?.call(v);
                },
              ),
            ),
          ),
          IgnorePointer(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) {
                final text = value.text;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < OtpBoxes.length; i++)
                      _box(
                        t,
                        i < text.length ? text[i] : '',
                        active:
                            _focus.hasFocus &&
                            (i == text.length ||
                                (i == OtpBoxes.length - 1 &&
                                    text.length == OtpBoxes.length)),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(EventraTokens t, String digit, {required bool active}) {
    final borderColor = widget.hasError
        ? t.error
        : active
        ? t.primary
        : digit.isNotEmpty
        ? t.primary.withValues(alpha: 0.35)
        : Colors.transparent;
    return AnimatedContainer(
      duration: t.motion.fast,
      width: 48,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: active ? t.primaryGlow : null,
      ),
      child: AnimatedScale(
        scale: digit.isEmpty ? 0.6 : 1,
        duration: t.motion.fast,
        child: Text(
          digit,
          style: EventraText.cardTitle.copyWith(fontSize: 24),
        ),
      ),
    );
  }
}

/// "Demo code: 123456" hint, only in debug builds (spec: OTP).
class DemoCodeHint extends StatelessWidget {
  const DemoCodeHint({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      key: const ValueKey('otp-demo-hint'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: t.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Debug build: the demo code is $kDemoOtpCode',
        style: EventraText.caption.copyWith(color: t.primary),
      ),
    );
  }
}

/// Plain text button in the primary color.
class AuthLinkButton extends StatelessWidget {
  const AuthLinkButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.bold = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: t.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        minimumSize: const Size(48, 44),
      ),
      child: Text(
        label,
        style: EventraText.body.copyWith(
          color: onPressed == null ? t.textHint : t.primary,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
