import 'dart:async';

import 'package:eventra/core/map/map_layers.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/organizer/domain/event_draft.dart';
import 'package:eventra/features/organizer/presentation/organizer_providers.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

/// Localized message for a wizard validation problem.
String draftIssueText(AppLocalizations l, DraftIssue issue) => switch (issue) {
  DraftIssue.titleLength => l.wizErrTitle(
    DraftValidator.titleMin,
    DraftValidator.titleMax,
  ),
  DraftIssue.categoryMissing => l.wizErrCategory,
  DraftIssue.descriptionLength => l.wizErrDescription(
    DraftValidator.descriptionMin,
  ),
  DraftIssue.startMissing => l.wizErrStart,
  DraftIssue.startInPast => l.wizErrStartPast,
  DraftIssue.endMissing => l.wizErrEnd,
  DraftIssue.endBeforeStart => l.wizErrEndBefore,
  DraftIssue.tooLong => l.wizErrTooLong,
  DraftIssue.venueLength => l.wizErrVenue,
  DraftIssue.addressLength => l.wizErrAddress,
  DraftIssue.pinMissing => l.wizErrPin,
  DraftIssue.tiersCount => l.wizErrTiers(DraftValidator.maxTiers),
  DraftIssue.tierName => l.wizErrTierName,
  DraftIssue.tierNameDuplicate => l.wizErrTierDuplicate,
  DraftIssue.tierPrice => l.wizErrTierPrice,
  DraftIssue.tierCapacity => l.wizErrTierCapacity,
  DraftIssue.tierBelowSold => l.wizErrTierBelowSold,
  DraftIssue.coverMissing => l.wizErrCover,
};

String wizardStepTitle(AppLocalizations l, WizardStep s) => switch (s) {
  WizardStep.basics => l.wizStepBasics,
  WizardStep.schedule => l.wizStepSchedule,
  WizardStep.venue => l.wizStepVenue,
  WizardStep.tiers => l.wizStepTiers,
  WizardStep.cover => l.wizStepCover,
  WizardStep.review => l.wizStepReview,
};

/// Create or edit an event in six steps. The draft autosaves (debounced)
/// on every change and when leaving, so nothing typed is lost.
///
/// Open with [draftId] to resume a draft, [eventId] to edit a published
/// event, or neither for a new event.
class EventWizardScreen extends ConsumerStatefulWidget {
  const EventWizardScreen({super.key, this.draftId, this.eventId});
  final String? draftId;
  final String? eventId;

  @override
  ConsumerState<EventWizardScreen> createState() => _EventWizardScreenState();
}

class _EventWizardScreenState extends ConsumerState<EventWizardScreen> {
  EventDraft? _draft;
  Object? _loadError;
  WizardStep _step = WizardStep.basics;
  var _showErrors = false;
  var _publishing = false;
  var _dirty = false;
  Timer? _autosave;

  // Text fields keep their own controllers so typing never jumps the caret.
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _venue = TextEditingController();
  final _address = TextEditingController();
  final _tierNames = <String, TextEditingController>{};
  final _tierPrices = <String, TextEditingController>{};
  final _tierCaps = <String, TextEditingController>{};
  final _badPrice = <String>{};

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final repo = ref.read(organizerRepositoryProvider);
    try {
      EventDraft? d;
      if (widget.draftId != null) {
        d = await repo.draft(widget.draftId!);
        if (d == null) throw StateError('draft not found');
      } else if (widget.eventId != null) {
        final e = await ref.read(eventByIdProvider(widget.eventId!).future);
        final sold = await repo.soldByTier(e.id);
        d = EventDraft.fromEvent(e, draftId: repo.newDraftId());
        d = d.copyWith(
          tiers: [
            for (final t in d.tiers)
              DraftTier(
                id: t.id,
                name: t.name,
                priceCents: t.priceCents,
                capacity: t.capacity,
                sold: sold[t.id] ?? t.sold,
              ),
          ],
        );
      } else {
        d = EventDraft(id: repo.newDraftId());
      }
      if (!mounted) return;
      _title.text = d.title;
      _description.text = d.description;
      _venue.text = d.venue;
      _address.text = d.address;
      for (final t in d.tiers) {
        _bindTier(t);
      }
      setState(() => _draft = d);
    } on Object catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  void _bindTier(DraftTier t) {
    _tierNames[t.id] = TextEditingController(text: t.name);
    _tierPrices[t.id] = TextEditingController(
      text: t.priceCents == 0 && t.name.isEmpty
          ? ''
          : (t.priceCents / 100).toStringAsFixed(
              t.priceCents % 100 == 0 ? 0 : 2,
            ),
    );
    _tierCaps[t.id] = TextEditingController(
      text: t.capacity == 0 ? '' : '${t.capacity}',
    );
  }

  @override
  void dispose() {
    _autosave?.cancel();
    if (_dirty && _draft != null && !_publishing) {
      unawaited(_save(silent: true));
    }
    for (final c in [
      _title,
      _description,
      _venue,
      _address,
      ..._tierNames.values,
      ..._tierPrices.values,
      ..._tierCaps.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime get _now => ref.read(clockProvider)();

  void _update(EventDraft Function(EventDraft d) change) {
    final d = _draft;
    if (d == null) return;
    setState(() {
      _draft = change(d);
      _dirty = true;
    });
    _autosave?.cancel();
    _autosave = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save({bool silent = false}) async {
    final d = _draft;
    final user = ref.read(authControllerProvider).user;
    if (d == null || user == null) return;
    _dirty = false;
    try {
      await ref.read(organizerRepositoryProvider).saveDraft(user.id, d);
      ref.read(organizerRevisionProvider.notifier).bump();
    } on Object {
      // The next change retries; publishing reports its own errors.
    }
  }

  List<DraftError> get _errors => _draft == null
      ? const []
      : DraftValidator.step(_step, _draft!, now: _now);

  String? _err(DraftIssue issue, {int? tier}) {
    if (!_showErrors) return null;
    return _errors.any((e) => e.issue == issue && e.tier == tier)
        ? draftIssueText(context.l10n, issue)
        : null;
  }

  void _next() {
    if (_badPrice.isNotEmpty && _step == WizardStep.tiers) {
      setState(() => _showErrors = true);
      return;
    }
    if (_errors.isNotEmpty) {
      setState(() => _showErrors = true);
      unawaited(HapticFeedback.lightImpact());
      return;
    }
    setState(() {
      _showErrors = false;
      _step = WizardStep.values[_step.index + 1];
    });
  }

  void _back() {
    if (_step.index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _showErrors = false;
      _step = WizardStep.values[_step.index - 1];
    });
  }

  Future<void> _publish() async {
    final d = _draft;
    final user = ref.read(authControllerProvider).user;
    final identity = ref.read(organizerIdentityProvider);
    if (d == null || user == null || identity == null) return;
    final invalid = DraftValidator.firstInvalidStep(d, now: _now);
    if (invalid != null) {
      setState(() {
        _step = invalid;
        _showErrors = true;
      });
      return;
    }
    setState(() => _publishing = true);
    _autosave?.cancel();
    final l = context.l10n;
    try {
      final event = await ref
          .read(organizerRepositoryProvider)
          .publish(
            ownerId: user.id,
            draft: d,
            organizer: identity.toOrganizer(),
            policy: l.wizDefaultPolicy,
          );
      _dirty = false;
      ref.read(organizerRevisionProvider.notifier).bump();
      await ref.read(eventsProvider.notifier).refresh();
      ref.invalidate(eventByIdProvider(event.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(d.isEdit ? l.wizUpdated : l.wizPublished)),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/organizer/dashboard');
      }
    } on Object {
      if (!mounted) return;
      setState(() => _publishing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.wizPublishFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final d = _draft;
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: MessageView(
            icon: Icons.edit_off_rounded,
            title: l.errorTitle,
            message: l.errEventGone,
          ),
        ),
      );
    }
    if (d == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final last = _step == WizardStep.review;
    final progress = (_step.index + 1) / WizardStep.values.length;
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          key: const ValueKey('wiz-back'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: _back,
          icon: const BackButtonIcon(),
        ),
        title: Text(d.isEdit ? l.wizEditTitle : l.wizNewTitle),
        actions: [
          TextButton(
            key: const ValueKey('wiz-save-draft'),
            onPressed: () async {
              await _save();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l.wizDraftSaved)));
            },
            child: Text(l.wizSaveDraft),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.wizStepOf(_step.index + 1, WizardStep.values.length),
                  style: context.text.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  wizardStepTitle(l, _step),
                  key: ValueKey('wiz-step-${_step.name}'),
                  style: context.text.sectionTitle,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: t.primary,
                    backgroundColor: t.primary.withValues(alpha: 0.14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: t.motion.medium,
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [_stepBody(d)],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: GradientPillButton(
                key: ValueKey(last ? 'wiz-publish' : 'wiz-next'),
                label: last
                    ? (d.isEdit ? l.wizSaveChanges : l.wizPublish)
                    : l.wizNext,
                icon: last ? Icons.rocket_launch_rounded : null,
                onPressed: _publishing ? null : (last ? _publish : _next),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBody(EventDraft d) => switch (_step) {
    WizardStep.basics => _basics(d),
    WizardStep.schedule => _schedule(d),
    WizardStep.venue => _venueStep(d),
    WizardStep.tiers => _tiers(d),
    WizardStep.cover => _cover(d),
    WizardStep.review => _review(d),
  };

  InputDecoration _input(String label, {String? error, String? hint}) {
    final t = context.tokens;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      errorMaxLines: 2,
      filled: true,
      fillColor: t.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: t.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: t.outline),
      ),
    );
  }

  Widget _errorLine(String? text) => text == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            text,
            style: context.text.caption.copyWith(color: context.tokens.error),
          ),
        );

  Widget _basics(EventDraft d) {
    final l = context.l10n;
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('wiz-title'),
          controller: _title,
          maxLength: DraftValidator.titleMax,
          textCapitalization: TextCapitalization.sentences,
          decoration: _input(
            l.wizTitle,
            error: _err(DraftIssue.titleLength),
          ),
          onChanged: (v) => _update((d) => d.copyWith(title: v)),
        ),
        const SizedBox(height: 12),
        Text(
          l.wizCategory,
          style: context.text.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in EventCategory.values)
              ChoiceChip(
                key: ValueKey('wiz-cat-${c.name}'),
                avatar: Icon(
                  c.icon,
                  size: 18,
                  color: d.category == c ? Colors.white : t.primary,
                ),
                label: Text(c.label),
                selected: d.category == c,
                showCheckmark: false,
                selectedColor: t.primary,
                labelStyle: TextStyle(
                  color: d.category == c ? Colors.white : t.textPrimary,
                ),
                onSelected: (_) => _update((d) => d.copyWith(category: c)),
              ),
          ],
        ),
        _errorLine(_err(DraftIssue.categoryMissing)),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('wiz-description'),
          controller: _description,
          minLines: 4,
          maxLines: 8,
          maxLength: DraftValidator.descriptionMax,
          textCapitalization: TextCapitalization.sentences,
          decoration: _input(
            l.wizDescription,
            error: _err(DraftIssue.descriptionLength),
          ),
          onChanged: (v) => _update((d) => d.copyWith(description: v)),
        ),
      ],
    );
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = _now;
    final base = initial ?? DateTime(now.year, now.month, now.day + 7, 20);
    final date = await showDatePicker(
      context: context,
      initialDate: base.isBefore(now) ? now : base,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Widget _dateTile({
    required Key key,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
    String? error,
  }) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            key: key,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: error == null ? t.outline : t.error),
            ),
            leading: Icon(Icons.event_rounded, color: t.primary),
            title: Text(label, style: context.text.caption),
            subtitle: Text(
              value == null ? context.l10n.wizPick : formatDateTime(value),
              style: context.text.cardTitle.copyWith(fontSize: 16),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: t.textHint),
            onTap: () async {
              final v = await _pickDateTime(value);
              if (v != null) onPicked(v);
            },
          ),
        ),
        _errorLine(error),
      ],
    );
  }

  Widget _schedule(EventDraft d) {
    final l = context.l10n;
    final duration =
        d.startAt != null && d.endAt != null && d.endAt!.isAfter(d.startAt!)
        ? d.endAt!.difference(d.startAt!)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _dateTile(
          key: const ValueKey('wiz-start'),
          label: l.wizStarts,
          value: d.startAt,
          error: _err(DraftIssue.startMissing) ?? _err(DraftIssue.startInPast),
          onPicked: (v) => _update((d) {
            // Keep the same length when the start moves; default to 3 h.
            final len =
                d.startAt != null &&
                    d.endAt != null &&
                    d.endAt!.isAfter(d.startAt!)
                ? d.endAt!.difference(d.startAt!)
                : const Duration(hours: 3);
            return d.copyWith(startAt: v, endAt: v.add(len));
          }),
        ),
        const SizedBox(height: 12),
        _dateTile(
          key: const ValueKey('wiz-end'),
          label: l.wizEnds,
          value: d.endAt,
          error:
              _err(DraftIssue.endMissing) ??
              _err(DraftIssue.endBeforeStart) ??
              _err(DraftIssue.tooLong),
          onPicked: (v) => _update((d) => d.copyWith(endAt: v)),
        ),
        if (duration != null) ...[
          const SizedBox(height: 12),
          Text(
            l.wizDuration(duration.inHours, duration.inMinutes % 60),
            style: context.text.caption,
          ),
        ],
      ],
    );
  }

  Widget _venueStep(EventDraft d) {
    final l = context.l10n;
    final t = context.tokens;
    final origin = ref.read(userLocationProvider).position;
    final pin = d.hasPin ? LatLng(d.latitude!, d.longitude!) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('wiz-venue'),
          controller: _venue,
          maxLength: DraftValidator.venueMax,
          decoration: _input(
            l.wizVenueName,
            error: _err(DraftIssue.venueLength),
          ),
          onChanged: (v) => _update((d) => d.copyWith(venue: v)),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('wiz-address'),
          controller: _address,
          maxLength: DraftValidator.addressMax,
          decoration: _input(
            l.wizAddress,
            error: _err(DraftIssue.addressLength),
          ),
          onChanged: (v) => _update((d) => d.copyWith(address: v)),
        ),
        const SizedBox(height: 8),
        Text(l.wizPinHint, style: context.text.caption),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(t.radii.miniMap),
          child: SizedBox(
            height: 260,
            child: Stack(
              children: [
                FlutterMap(
                  key: const ValueKey('wiz-map'),
                  options: MapOptions(
                    initialCenter: pin ?? origin,
                    initialZoom: 14,
                    backgroundColor: t.mapBackground,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, p) => _update(
                      (d) => d.copyWith(
                        latitude: p.latitude,
                        longitude: p.longitude,
                      ),
                    ),
                  ),
                  children: [
                    const PositronTileLayer(),
                    if (pin != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pin,
                            width: 44,
                            height: 44,
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.location_on_rounded,
                              key: const ValueKey('wiz-pin'),
                              color: t.primary,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const PositionedDirectional(
                  end: 8,
                  bottom: 6,
                  child: MapAttribution(),
                ),
                PositionedDirectional(
                  start: 8,
                  bottom: 6,
                  child: FilledButton.tonalIcon(
                    key: const ValueKey('wiz-pin-here'),
                    onPressed: () => _update(
                      (d) => d.copyWith(
                        latitude: origin.latitude,
                        longitude: origin.longitude,
                      ),
                    ),
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(l.wizPinHere),
                  ),
                ),
              ],
            ),
          ),
        ),
        _errorLine(_err(DraftIssue.pinMissing)),
        if (pin != null) ...[
          const SizedBox(height: 8),
          Text(
            '${pin.latitude.toStringAsFixed(5)}, '
            '${pin.longitude.toStringAsFixed(5)}',
            key: const ValueKey('wiz-pin-coords'),
            style: context.text.caption,
          ),
        ],
      ],
    );
  }

  void _setTier(int i, DraftTier Function(DraftTier t) change) => _update(
    (d) => d.copyWith(
      tiers: [
        for (final (j, t) in d.tiers.indexed)
          if (j == i) change(t) else t,
      ],
    ),
  );

  Widget _tiers(EventDraft d) {
    final l = context.l10n;
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, tier) in d.tiers.indexed) ...[
          Container(
            key: ValueKey('wiz-tier-$i'),
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(t.radii.thumbnail),
              border: Border.all(color: t.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.wizTierN(i + 1),
                        style: context.text.cardTitle.copyWith(fontSize: 16),
                      ),
                    ),
                    if (d.tiers.length > 1 && tier.sold == 0)
                      IconButton(
                        key: ValueKey('wiz-tier-remove-$i'),
                        tooltip: l.orgDelete,
                        onPressed: () => _update(
                          (d) => d.copyWith(
                            tiers: [...d.tiers]..removeAt(i),
                          ),
                        ),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: t.textHint,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: TextField(
                    key: ValueKey('wiz-tier-name-$i'),
                    controller: _tierNames[tier.id],
                    maxLength: DraftValidator.tierNameMax,
                    decoration: _input(
                      l.wizTierName,
                      hint: l.wizTierNameHint,
                      error:
                          _err(DraftIssue.tierName, tier: i) ??
                          _err(DraftIssue.tierNameDuplicate, tier: i),
                    ),
                    onChanged: (v) => _setTier(i, (t) => t.copyWith(name: v)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          key: ValueKey('wiz-tier-price-$i'),
                          controller: _tierPrices[tier.id],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _input(
                            l.wizTierPrice,
                            hint: '0',
                            error: _showErrors && _badPrice.contains(tier.id)
                                ? l.wizErrTierPrice
                                : _err(DraftIssue.tierPrice, tier: i),
                          ).copyWith(prefixText: r'$ '),
                          onChanged: (v) {
                            final cents = parsePriceCents(v);
                            setState(() {
                              if (cents == null) {
                                _badPrice.add(tier.id);
                              } else {
                                _badPrice.remove(tier.id);
                              }
                            });
                            if (cents != null) {
                              _setTier(i, (t) => t.copyWith(priceCents: cents));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: ValueKey('wiz-tier-cap-$i'),
                          controller: _tierCaps[tier.id],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _input(
                            l.wizTierCapacity,
                            error:
                                _err(DraftIssue.tierCapacity, tier: i) ??
                                (_err(DraftIssue.tierBelowSold, tier: i) == null
                                    ? null
                                    : l.wizErrTierBelowSoldN(tier.sold)),
                          ),
                          onChanged: (v) => _setTier(
                            i,
                            (t) => t.copyWith(capacity: int.tryParse(v) ?? 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (tier.priceCents == 0 && tier.name.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l.wizFreeTier, style: context.text.caption),
                  ),
              ],
            ),
          ),
        ],
        _errorLine(_err(DraftIssue.tiersCount)),
        if (d.tiers.length < DraftValidator.maxTiers)
          OutlinedButton.icon(
            key: const ValueKey('wiz-tier-add'),
            style: OutlinedButton.styleFrom(
              foregroundColor: t.primary,
              shape: const StadiumBorder(),
              side: BorderSide(color: t.primary.withValues(alpha: 0.4)),
            ),
            onPressed: () {
              final tier = DraftTier(
                id: 't${DateTime.now().microsecondsSinceEpoch}',
              );
              _bindTier(tier);
              _update((d) => d.copyWith(tiers: [...d.tiers, tier]));
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l.wizAddTier),
          ),
        const SizedBox(height: 12),
        Text(
          l.wizCapacityTotal(d.totalCapacity),
          key: const ValueKey('wiz-capacity-total'),
          style: context.text.caption,
        ),
      ],
    );
  }

  Widget _cover(EventDraft d) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 4 / 3,
          children: [
            for (final (i, url) in kCoverChoices.indexed)
              Semantics(
                selected: d.coverUrl == url,
                button: true,
                label: context.l10n.wizCoverN(i + 1),
                child: GestureDetector(
                  key: ValueKey('wiz-cover-$i'),
                  onTap: () => _update((d) => d.copyWith(coverUrl: url)),
                  child: AnimatedContainer(
                    duration: t.motion.fast,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(t.radii.thumbnail),
                      border: Border.all(
                        color: d.coverUrl == url
                            ? t.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        t.radii.thumbnail - 3,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          EventImage(
                            url: url,
                            category: d.category,
                            cacheWidth: 400,
                          ),
                          if (d.coverUrl == url)
                            PositionedDirectional(
                              top: 8,
                              end: 8,
                              child: CircleAvatar(
                                radius: 13,
                                backgroundColor: t.primary,
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        _errorLine(_err(DraftIssue.coverMissing)),
        const SizedBox(height: 12),
        Text(context.l10n.wizCoverCredit, style: context.text.caption),
      ],
    );
  }

  Widget _review(EventDraft d) {
    final t = context.tokens;
    final l = context.l10n;
    final problems = DraftValidator.all(d, now: _now);
    Widget row(IconData icon, String text, WizardStep step) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: t.primary),
      title: Text(
        text,
        style: context.text.body.copyWith(color: t.textPrimary),
      ),
      trailing: TextButton(
        key: ValueKey('wiz-review-edit-${step.name}'),
        onPressed: () => setState(() => _step = step),
        child: Text(l.orgEdit),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (d.coverUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(t.radii.eventCard),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: EventImage(url: d.coverUrl!, category: d.category),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          context.bidi(d.title.trim()),
          style: context.text.detailsTitle,
        ),
        if (d.category != null)
          Text(d.category!.label, style: context.text.caption),
        const SizedBox(height: 8),
        if (d.startAt != null && d.endAt != null)
          row(
            Icons.schedule_rounded,
            formatPreviewRange(d.startAt!, d.endAt!),
            WizardStep.schedule,
          ),
        row(
          Icons.place_outlined,
          context.bidi('${d.venue.trim()} · ${d.address.trim()}'),
          WizardStep.venue,
        ),
        row(
          Icons.confirmation_number_outlined,
          [for (final tier in d.tiers) _tierSummary(l, tier)].join('\n'),
          WizardStep.tiers,
        ),
        if (problems.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            key: const ValueKey('wiz-review-problems'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              {for (final p in problems) draftIssueText(l, p.issue)}.join('\n'),
              style: context.text.caption.copyWith(color: t.error),
            ),
          ),
        ],
      ],
    );
  }
}

String _tierSummary(AppLocalizations l, DraftTier t) {
  final price = t.priceCents == 0 ? l.priceFree : formatCents(t.priceCents);
  return '${t.name.trim()} $price × ${t.capacity}';
}
