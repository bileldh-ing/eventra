import 'dart:async';
import 'dart:ui';

import 'package:eventra/core/map/map_layers.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/auth/domain/auth_models.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/cards.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/payment.dart';
import 'package:eventra/features/tickets/domain/pricing.dart';
import 'package:eventra/features/tickets/domain/promo.dart';
import 'package:eventra/features/tickets/domain/refund_policy.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/card_form_sheet.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticketing_widgets.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Checkout for a 10-minute hold: attendee details, promo code, payment
/// method, price breakdown and Pay. One idempotency key per attempt, so a
/// double tap never creates two orders; a failed attempt gets a new key.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({required this.holdId, super.key});
  final String holdId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  /// The hold as it was when checkout opened. Later changes (it converts
  /// into an order on success) must not swap the page out mid-flow.
  TicketHold? _opened;

  String get holdId => widget.holdId;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final live = ref.watch(holdProvider(holdId));
    if (_opened == null && live.hasValue && !live.isLoading) {
      _opened = live.value;
    }
    final hold = _opened != null ? AsyncData<TicketHold?>(_opened) : live;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final eventId = hold.value?.eventId;
    final event = eventId == null
        ? null
        : ref.watch(eventByIdProvider(eventId));

    Widget page(Widget child) => Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          TicketingHeader(
            title: context.l10n.coCheckout,
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(child: child),
        ],
      ),
    );

    if (hold.hasError || (event?.hasError ?? false)) {
      return page(
        MessageView.error(
          message: context.l10n.coLoadFailed,
          onRetry: () => ref.invalidate(holdProvider(holdId)),
        ),
      );
    }
    if (hold.isLoading && !hold.hasValue) {
      return page(const Center(child: CircularProgressIndicator()));
    }
    final h = hold.value;
    if (h == null || user == null || h.userId != user.id) {
      return page(
        MessageView(
          icon: Icons.receipt_long_outlined,
          title: context.l10n.coNotFound,
          message: context.l10n.coSelectionGone,
          actionLabel: context.l10n.back,
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    if (h.status == HoldStatus.converted) {
      return page(
        MessageView(
          icon: Icons.check_circle_outline_rounded,
          title: context.l10n.coAlreadyBooked,
          message: context.l10n.coInWallet,
          actionLabel: context.l10n.myTickets,
          onAction: () => context.go('/tickets'),
        ),
      );
    }
    final e = event?.value;
    if (e == null) {
      return page(const Center(child: CircularProgressIndicator()));
    }
    return _CheckoutBody(hold: h, event: e, user: user);
  }
}

enum _Stage { idle, processing, success }

class _CheckoutBody extends ConsumerStatefulWidget {
  const _CheckoutBody({
    required this.hold,
    required this.event,
    required this.user,
  });

  final TicketHold hold;
  final Event event;
  final AppUser user;

  @override
  ConsumerState<_CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends ConsumerState<_CheckoutBody> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.name);
  late final _email = TextEditingController(text: widget.user.email);
  final _promo = TextEditingController();

  PromoCode? _applied;
  String? _promoError;
  bool _checkingPromo = false;

  PaymentMethod? _method = SavedCardMethod(kDemoCards.first);
  NewCardMethod? _newCard;

  _Stage _stage = _Stage.idle;
  String? _error;
  bool _leaving = false;

  /// Idempotency key for the current payment attempt.
  String _key = TicketingRepository.newId('idem');

  DateTime Function() get _clock => ref.read(clockProvider);

  List<PriceLine> get _lines => linesFor(widget.event, widget.hold.lines);

  PriceQuote get _quote => priceOrder(_lines, promo: _applied);

  bool get _expired => !widget.hold.isLive(_clock());

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _promo.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _checkingPromo = true;
      _promoError = null;
    });
    final check = await ref
        .read(ticketingRepositoryProvider)
        .checkPromo(input: _promo.text, userId: widget.user.id, lines: _lines);
    if (!mounted) return;
    setState(() {
      _checkingPromo = false;
      if (check.ok) {
        _applied = check.promo;
        _promo.clear();
      } else {
        _promoError = check.error!.message;
      }
    });
  }

  Future<void> _addCard() async {
    final card = await showCardFormSheet(context, now: _clock());
    if (card == null || !mounted) return;
    setState(() {
      _newCard = card;
      _method = card;
    });
  }

  Future<bool> _authenticate(int amountCents) async {
    if (!mounted) return false;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThreeDsSheet(
        amountCents: amountCents,
        cardLabel: '${_method!.brand.label} •••• ${_method!.last4}',
      ),
    );
    return ok ?? false;
  }

  Future<void> _pay() async {
    if (_stage != _Stage.idle) return;
    if (_expired) {
      setState(() {});
      return;
    }
    if (!(_form.currentState?.validate() ?? false)) return;
    final quote = _quote;
    if (!quote.isFree && _method == null) {
      setState(() => _error = context.l10n.tkChoosePay);
      return;
    }
    setState(() {
      _stage = _Stage.processing;
      _error = null;
    });
    final result = await ref
        .read(ticketingActionsProvider)
        .pay(
          CheckoutRequest(
            holdId: widget.hold.id,
            userId: widget.user.id,
            event: widget.event,
            attendeeName: _name.text,
            attendeeEmail: _email.text,
            idempotencyKey: _key,
            promoCode: _applied?.code,
            method: quote.isFree ? null : _method,
            authenticate: _authenticate,
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Success(value: final order):
        setState(() => _stage = _Stage.success);
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        _leaving = true;
        context.pushReplacement('/booking-success/${order.id}');
      case Failure(:final failure):
        final code = failure is TicketingFailure ? failure.code : null;
        setState(() {
          _stage = _Stage.idle;
          _error = failure.message;
          // A new attempt gets a new key; the failed one stays recorded.
          _key = TicketingRepository.newId('idem');
          if (code == TicketingError.promoInvalid) _applied = null;
        });
    }
  }

  Future<void> _leave() async {
    if (_stage != _Stage.idle) return;
    if (_expired) {
      _leaving = true;
      Navigator.of(context).pop();
      return;
    }
    final release = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.coLeaveQ),
        content: Text(
          context.l10n.coLeaveBody,
        ),
        actions: [
          TextButton(
            key: const ValueKey('stay-checkout'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.coStay),
          ),
          TextButton(
            key: const ValueKey('release-hold'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.coRelease),
          ),
        ],
      ),
    );
    if (release != true || !mounted) return;
    await ref.read(ticketingActionsProvider).release(widget.hold.id);
    if (!mounted) return;
    _leaving = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final quote = _quote;
    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        backgroundColor: t.background,
        body: Stack(
          children: [
            Column(
              children: [
                TicketingHeader(title: context.l10n.coCheckout, onBack: _leave),
                ClockTicker(
                  clock: _clock,
                  builder: (context, now) => _HoldBanner(
                    hold: widget.hold,
                    now: now,
                    onRestart: () {
                      _leaving = true;
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _form,
                    child: ListView(
                      key: const ValueKey('checkout-scroll'),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        8,
                        20,
                        24,
                      ),
                      children: [
                        _summary(t),
                        const SizedBox(height: 16),
                        _attendee(),
                        const SizedBox(height: 16),
                        _promoSection(t),
                        if (!quote.isFree) ...[
                          const SizedBox(height: 16),
                          _payment(t),
                        ],
                        const SizedBox(height: 16),
                        SectionCard(
                          title: context.l10n.coPriceDetails,
                          child: PriceBreakdown(quote: quote),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: t.textHint,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                RefundPolicy.summary,
                                style: context.text.caption.copyWith(
                                  color: t.textHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _payBar(t, quote),
              ],
            ),
            if (_stage != _Stage.idle) _ProcessingOverlay(stage: _stage),
          ],
        ),
      ),
    );
  }

  Widget _summary(EventraTokens t) => SectionCard(
    title: widget.event.title,
    child: Column(
      children: [
        for (final l in _lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${l.quantity}×',
                    style: context.text.caption.copyWith(
                      color: t.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.tierName,
                    style: context.text.body.copyWith(color: t.textPrimary),
                  ),
                ),
                Text(
                  l.unitCents == 0
                      ? context.l10n.priceFree
                      : formatCents(l.subtotalCents),
                  style: context.text.body.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _attendee() => SectionCard(
    title: context.l10n.coAttendee,
    child: Column(
      children: [
        AuthField(
          key: const ValueKey('attendee-name'),
          controller: _name,
          label: context.l10n.fieldFullName,
          icon: Icons.person_outline_rounded,
          autofillHints: const [AutofillHints.name],
          validator: (v) =>
              (v ?? '').trim().length < 2 ? context.l10n.coEnterHolder : null,
        ),
        const SizedBox(height: 12),
        AuthField(
          key: const ValueKey('attendee-email'),
          controller: _email,
          label: context.l10n.coEmailForTickets,
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          validator: (v) =>
              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
              ? null
              : context.l10n.coValidEmail,
        ),
      ],
    ),
  );

  Widget _promoSection(EventraTokens t) => SectionCard(
    title: context.l10n.coPromo,
    child: AnimatedSize(
      duration: t.motion.medium,
      curve: t.motion.standard,
      child: _applied != null
          ? Row(
              key: const ValueKey('promo-applied'),
              children: [
                Icon(Icons.local_offer_rounded, color: t.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _applied!.code,
                        style: context.text.body.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        context.l10n.coPromoSaves(
                          _applied!.displayLabel,
                          formatCents(_quote.discountCents),
                        ),
                        style: context.text.caption.copyWith(color: t.success),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('promo-remove'),
                  tooltip: context.l10n.coRemovePromo,
                  onPressed: _stage == _Stage.idle
                      ? () => setState(() => _applied = null)
                      : null,
                  icon: Icon(Icons.close_rounded, color: t.textHint),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('promo-field'),
                        controller: _promo,
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (_) => _applyPromo(),
                        style: context.text.body.copyWith(
                          color: t.textPrimary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.coEnterCode,
                          hintStyle: context.text.body.copyWith(
                            color: t.textHint,
                          ),
                          filled: true,
                          fillColor: t.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 96,
                      child: GradientPillButton(
                        key: const ValueKey('promo-apply'),
                        label: _checkingPromo ? '…' : context.l10n.coApply,
                        height: 46,
                        onPressed: _checkingPromo ? null : _applyPromo,
                      ),
                    ),
                  ],
                ),
                if (_promoError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _promoError!,
                    key: const ValueKey('promo-error'),
                    style: context.text.caption.copyWith(color: t.error),
                  ),
                ],
              ],
            ),
    ),
  );

  Widget _payment(EventraTokens t) {
    final methods = <PaymentMethod>[
      for (final c in kDemoCards) SavedCardMethod(c),
      ?_newCard,
    ];
    bool isSelected(PaymentMethod m) => switch ((m, _method)) {
      (SavedCardMethod(:final card), SavedCardMethod(card: final sel)) =>
        card.id == sel.id,
      (NewCardMethod(), final NewCardMethod sel) => identical(m, sel),
      _ => false,
    };
    return SectionCard(
      title: context.l10n.coPayment,
      trailing: StatusChip(
        label: context.l10n.coDemoMode,
        color: t.accentOrange,
        icon: Icons.science_outlined,
      ),
      child: Column(
        children: [
          for (final m in methods)
            _MethodTile(
              method: m,
              selected: isSelected(m),
              onTap: _stage == _Stage.idle
                  ? () => setState(() => _method = m)
                  : null,
            ),
          const SizedBox(height: 4),
          Pressable(
            key: const ValueKey('add-card'),
            onTap: _stage == _Stage.idle ? _addCard : null,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: t.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_card_rounded, color: t.primary),
                  const SizedBox(width: 8),
                  Text(
                    _newCard == null
                        ? context.l10n.coAddCard
                        : context.l10n.coUseAnother,
                    style: context.text.body.copyWith(
                      color: t.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payBar(EventraTokens t, PriceQuote quote) {
    final expired = _expired;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        14,
        20,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: context.tokens.shadow(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            InlineBanner(
              key: const ValueKey('checkout-error'),
              message: _error!,
            ),
            const SizedBox(height: 10),
          ],
          GradientPillButton(
            key: const ValueKey('pay-button'),
            label: quote.isFree
                ? context.l10n.coConfirmFree
                : context.l10n.coPay(formatCents(quote.totalCents)),
            icon: Icons.lock_rounded,
            onPressed: expired || _stage != _Stage.idle ? null : _pay,
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (id, subtitle) = switch (method) {
      SavedCardMethod(:final card) => (
        card.id,
        context.l10n.coExpires(card.expiry),
      ),
      NewCardMethod(:final expiry) => (
        'new',
        context.l10n.coNewCardExpires(expiry),
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        button: true,
        label: context.l10n.coCardEnding(method.brand.label, method.last4),
        child: Pressable(
          key: ValueKey('method-$id'),
          onTap: onTap,
          child: AnimatedContainer(
            duration: t.motion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? t.primary.withValues(alpha: 0.06)
                  : t.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? t.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                _BrandBadge(brand: method.brand),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${method.brand.label} •••• ${method.last4}',
                        style: context.text.body.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(subtitle, style: context.text.caption),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? t.primary : t.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.brand});
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final colors = switch (brand) {
      CardBrand.visa => const [Color(0xFF1A1F71), Color(0xFF3D4BC2)],
      CardBrand.mastercard => const [Color(0xFFEB001B), Color(0xFFF79E1B)],
      CardBrand.amex => const [Color(0xFF016FD0), Color(0xFF3A9BEA)],
      CardBrand.discover => const [Color(0xFFE55C20), Color(0xFFF7A54A)],
      CardBrand.unknown => const [Color(0xFF8E8AA0), Color(0xFFB8B4C7)],
    };
    final short = switch (brand) {
      CardBrand.visa => 'VISA',
      CardBrand.mastercard => 'MC',
      CardBrand.amex => 'AMEX',
      CardBrand.discover => 'DISC',
      CardBrand.unknown => 'CARD',
    };
    return Container(
      width: 48,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        short,
        style: const TextStyle(
          fontFamily: kFontFamily,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Countdown for the hold; turns orange under 2 minutes and red under 1,
/// then offers to start over once it expires.
class _HoldBanner extends StatelessWidget {
  const _HoldBanner({
    required this.hold,
    required this.now,
    required this.onRestart,
  });

  final TicketHold hold;
  final DateTime now;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final left = hold.remaining(now);
    final total = hold.expiresAt.difference(hold.createdAt);
    final expired = left == Duration.zero;
    final color = expired || left.inSeconds < 60
        ? t.error
        : left.inSeconds < 120
        ? t.accentOrange
        : t.primary;
    final mm = left.inMinutes.toString().padLeft(2, '0');
    final ss = (left.inSeconds % 60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 8),
      child: AnimatedContainer(
        key: const ValueKey('hold-banner'),
        duration: t.motion.medium,
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CountdownRing(
              fraction: total.inSeconds == 0
                  ? 0
                  : left.inSeconds / total.inSeconds,
              label: expired ? '0' : mm,
              color: color,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                liveRegion: expired,
                child: Text(
                  expired
                      ? context.l10n.coHoldExpired
                      : context.l10n.coHeldFor('$mm:$ss'),
                  key: const ValueKey('hold-text'),
                  style: context.text.body.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (expired)
              TextButton(
                key: const ValueKey('hold-restart'),
                onPressed: onRestart,
                child: Text(context.l10n.coChooseAgain),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThreeDsSheet extends StatelessWidget {
  const _ThreeDsSheet({required this.amountCents, required this.cardLabel});
  final int amountCents;
  final String cardLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      key: const ValueKey('three-ds-sheet'),
      margin: const EdgeInsets.all(12),
      padding: EdgeInsetsDirectional.fromSTEB(
        24,
        24,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radii.sheet),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, color: t.primary, size: 32),
          ),
          const SizedBox(height: 14),
          Text(context.l10n.co3dsTitle, style: context.text.cardTitle),
          const SizedBox(height: 8),
          Text(
            context.l10n.co3dsBody(formatCents(amountCents), cardLabel),
            textAlign: TextAlign.center,
            style: context.text.body,
          ),
          const SizedBox(height: 22),
          GradientPillButton(
            key: const ValueKey('three-ds-approve'),
            label: context.l10n.coApprove,
            icon: Icons.fingerprint_rounded,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 6),
          TextButton(
            key: const ValueKey('three-ds-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class _ProcessingOverlay extends ConsumerWidget {
  const _ProcessingOverlay({required this.stage});
  final _Stage stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final looping = ref.watch(loopingAnimationsProvider);
    final done = stage == _Stage.success;
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColoredBox(
          color: const Color(0x66120F1F),
          child: Center(
            child: Container(
              key: ValueKey(done ? 'payment-success' : 'payment-processing'),
              width: 220,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(t.radii.listCard),
                boxShadow: t.softShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 72,
                    child: AnimatedSwitcher(
                      duration: t.motion.medium,
                      transitionBuilder: (c, a) => ScaleTransition(
                        scale: CurvedAnimation(
                          parent: a,
                          curve: Curves.elasticOut,
                        ),
                        child: c,
                      ),
                      child: done
                          ? Container(
                              key: const ValueKey('check'),
                              decoration: BoxDecoration(
                                gradient: t.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: t.primaryGlow,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                            )
                          : Padding(
                              key: const ValueKey('spinner'),
                              padding: const EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                // Static in tests so pumpAndSettle settles.
                                value: looping ? null : 0.7,
                                strokeWidth: 4,
                                color: t.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    done
                        ? context.l10n.coPaymentConfirmed
                        : context.l10n.coProcessing,
                    textAlign: TextAlign.center,
                    style: context.text.cardTitle.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    done ? context.l10n.coIssuing : context.l10n.coKeepOpen,
                    textAlign: TextAlign.center,
                    style: context.text.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
