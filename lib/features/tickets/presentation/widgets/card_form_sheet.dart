import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Opens the new-card form; resolves to the card, or null if dismissed.
/// The number lives only in memory for this checkout.
Future<NewCardMethod?> showCardFormSheet(
  BuildContext context, {
  required DateTime now,
}) => showModalBottomSheet<NewCardMethod>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => CardFormSheet(now: now),
);

class CardFormSheet extends StatefulWidget {
  const CardFormSheet({required this.now, super.key});
  final DateTime now;

  @override
  State<CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<CardFormSheet> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  final _name = TextEditingController();
  CardBrand _brand = CardBrand.unknown;

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _cvc.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop(NewCardMethod(number: _number.text, expiry: _expiry.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: Container(
        key: const ValueKey('card-sheet'),
        padding: EdgeInsetsDirectional.fromSTEB(
          24,
          12,
          24,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(t.radii.sheet),
          ),
        ),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.tokens.disabled,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.cfAddCard,
                        style: context.text.cardTitle,
                      ),
                    ),
                    Text(
                      _brand == CardBrand.unknown ? '' : _brand.label,
                      key: const ValueKey('card-brand'),
                      style: context.text.body.copyWith(
                        color: t.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AuthField(
                  key: const ValueKey('card-number'),
                  controller: _number,
                  label: context.l10n.cfNumber,
                  icon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardNumber],
                  onChanged: (v) =>
                      setState(() => _brand = CardBrand.detect(v)),
                  inputFormatters: [_CardNumberFormatter()],
                  validator: (v) => validateCardNumber(v ?? ''),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AuthField(
                        key: const ValueKey('card-expiry'),
                        controller: _expiry,
                        label: 'MM/YY',
                        icon: Icons.event_rounded,
                        keyboardType: TextInputType.number,
                        autofillHints: const [
                          AutofillHints.creditCardExpirationDate,
                        ],
                        inputFormatters: [_ExpiryFormatter()],
                        validator: (v) => validateExpiry(v ?? '', widget.now),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthField(
                        key: const ValueKey('card-cvc'),
                        controller: _cvc,
                        label: 'CVC',
                        icon: Icons.lock_outline_rounded,
                        keyboardType: TextInputType.number,
                        obscure: true,
                        autofillHints: const [
                          AutofillHints.creditCardSecurityCode,
                        ],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (v) => validateCvc(v ?? '', _brand),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AuthField(
                  key: const ValueKey('card-name'),
                  controller: _name,
                  label: context.l10n.cfName,
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.creditCardName],
                  onSubmitted: (_) => _submit(),
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? context.l10n.cfEnterName
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.cfDemo,
                  style: context.text.caption.copyWith(color: t.textHint),
                ),
                const SizedBox(height: 18),
                GradientPillButton(
                  key: const ValueKey('card-save'),
                  label: context.l10n.cfUse,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = digitsOnly(newValue.text);
    if (digits.length > 19) digits = digits.substring(0, 19);
    final text = formatCardNumber(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = digitsOnly(newValue.text);
    if (digits.length > 4) digits = digits.substring(0, 4);
    final deleting = newValue.text.length < oldValue.text.length;
    final text = digits.length > 2 || (digits.length == 2 && !deleting)
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
