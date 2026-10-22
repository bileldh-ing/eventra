import 'dart:async';

import 'package:eventra/core/map/map_layers.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/organizer/domain/check_in.dart';
import 'package:eventra/features/organizer/presentation/organizer_format.dart';
import 'package:eventra/features/organizer/presentation/organizer_providers.dart';
import 'package:eventra/features/organizer/presentation/widgets/code_scanner.dart';
import 'package:eventra/features/organizer/presentation/widgets/scan_result_sheet.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The door: a camera scanner (with typed-code fallback) and the attendee
/// list with search and manual check-in. Works offline; check-ins queue and
/// sync when the connection returns.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({required this.eventId, super.key});
  final String eventId;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  bool _cameraUnavailable = false;
  bool _busy = false;
  String? _lastCode;
  DateTime? _lastAt;

  Future<void> _handle(Future<CheckInResult> Function() run) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final r = await run();
      if (!mounted) return;
      await showScanResult(context, r);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onCode(String code) {
    // The camera reports the same frame many times: ignore repeats of the
    // code just handled for a few seconds.
    final now = DateTime.now();
    if (code == _lastCode &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastCode = code;
    _lastAt = now;
    unawaited(
      _handle(
        () => ref
            .read(checkInControllerProvider)
            .scan(code, eventId: widget.eventId),
      ),
    );
  }

  Future<void> _enterCode() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.tokens.sheet,
      builder: (_) => const _ManualCodeSheet(),
    );
    if (code == null || code.trim().isEmpty || !mounted) return;
    await _handle(
      () => ref
          .read(checkInControllerProvider)
          .enter(code, eventId: widget.eventId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final event = ref.watch(eventByIdProvider(widget.eventId));
    final attendees = ref.watch(attendeesProvider(widget.eventId));
    final pending = ref.watch(pendingCheckInsProvider).value ?? 0;
    final list = attendees.value ?? const <Attendee>[];
    final active = list.where((a) => !a.cancelled).toList();
    final inCount = active.where((a) => a.checkedIn).length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: t.background,
        appBar: AppBar(
          backgroundColor: t.background,
          surfaceTintColor: Colors.transparent,
          title: Text(
            context.bidi(event.value?.title ?? l.orgCheckIn),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            labelColor: t.primary,
            unselectedLabelColor: t.textSecondary,
            indicatorColor: t.primary,
            tabs: [
              Tab(key: const ValueKey('tab-scan'), text: l.orgScanTab),
              Tab(key: const ValueKey('tab-list'), text: l.orgGuestsTab),
            ],
          ),
        ),
        body: Column(
          children: [
            _CounterBar(
              checkedIn: inCount,
              total: active.length,
              pending: pending,
              onSync: () async {
                final left = await ref.read(checkInControllerProvider).flush();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      left == 0 ? l.orgSynced : l.orgSyncOffline(left),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ScanTab(
                    cameraUnavailable: _cameraUnavailable,
                    busy: _busy,
                    preview: ref
                        .watch(codeScannerProvider)
                        .preview(
                          onCode: _onCode,
                          onUnavailable: () {
                            if (mounted) {
                              setState(() => _cameraUnavailable = true);
                            }
                          },
                        ),
                    onEnterCode: _enterCode,
                  ),
                  _GuestList(
                    attendees: list,
                    loading: attendees.isLoading && list.isEmpty,
                    onCheckIn: (a) => _handle(
                      () => ref
                          .read(checkInControllerProvider)
                          .manual(a.ticketId, eventId: widget.eventId),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBar extends StatelessWidget {
  const _CounterBar({
    required this.checkedIn,
    required this.total,
    required this.pending,
    required this.onSync,
  });
  final int checkedIn;
  final int total;
  final int pending;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Icon(Icons.how_to_reg_rounded, color: t.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.orgCheckedInOf(
                formatCount(checkedIn),
                formatCount(total),
              ),
              key: const ValueKey('checkin-counter'),
              style: context.text.cardTitle.copyWith(fontSize: 16),
            ),
          ),
          if (pending > 0)
            ActionChip(
              key: const ValueKey('checkin-pending'),
              avatar: Icon(
                Icons.cloud_off_rounded,
                size: 16,
                color: t.accentOrange,
              ),
              label: Text(context.l10n.orgPendingSync(pending)),
              onPressed: onSync,
            ),
        ],
      ),
    );
  }
}

class _ScanTab extends StatelessWidget {
  const _ScanTab({
    required this.cameraUnavailable,
    required this.busy,
    required this.preview,
    required this.onEnterCode,
  });
  final bool cameraUnavailable;
  final bool busy;
  final Widget preview;
  final VoidCallback onEnterCode;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(t.radii.eventCard),
              child: ColoredBox(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!cameraUnavailable) preview,
                    if (cameraUnavailable)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l.orgCameraUnavailable,
                            key: const ValueKey('camera-unavailable'),
                            textAlign: TextAlign.center,
                            style: context.text.body.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      const _ScanFrame(),
                    if (busy)
                      const ColoredBox(
                        color: Color(0x66000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.orgScanHint,
            textAlign: TextAlign.center,
            style: context.text.caption,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              key: const ValueKey('enter-code'),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.primary,
                side: BorderSide(color: t.primary.withValues(alpha: 0.5)),
                shape: const StadiumBorder(),
              ),
              onPressed: busy ? null : onEnterCode,
              icon: const Icon(Icons.keyboard_alt_outlined),
              label: Text(l.orgEnterCode),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded corner brackets with a scan line that sweeps while scanning.
class _ScanFrame extends ConsumerStatefulWidget {
  const _ScanFrame();

  @override
  ConsumerState<_ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends ConsumerState<_ScanFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    final reduce = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (!reduce && ref.read(loopingAnimationsProvider)) {
      unawaited(_c.repeat(reverse: true));
    } else {
      _c.value = 0.5;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.primaryLight;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _FramePainter(_c.value, color),
            ),
          ),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const r = 22.0;
    const len = 34.0;
    final w = size.width;
    final h = size.height;
    void corner(Offset o, double sx, double sy) {
      final path = Path()
        ..moveTo(o.dx, o.dy + sy * (r + len))
        ..lineTo(o.dx, o.dy + sy * r)
        ..arcToPoint(
          Offset(o.dx + sx * r, o.dy),
          radius: const Radius.circular(r),
          clockwise: sx * sy > 0,
        )
        ..lineTo(o.dx + sx * (r + len), o.dy);
      canvas.drawPath(path, p);
    }

    corner(Offset.zero, 1, 1);
    corner(Offset(w, 0), -1, 1);
    corner(Offset(0, h), 1, -1);
    corner(Offset(w, h), -1, -1);
    final y = 14 + (h - 28) * t;
    canvas.drawLine(
      Offset(18, y),
      Offset(w - 18, y),
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color,
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, y - 1, w, 2))
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.t != t || old.color != color;
}

class _GuestList extends StatefulWidget {
  const _GuestList({
    required this.attendees,
    required this.loading,
    required this.onCheckIn,
  });
  final List<Attendee> attendees;
  final bool loading;
  final ValueChanged<Attendee> onCheckIn;

  @override
  State<_GuestList> createState() => _GuestListState();
}

class _GuestListState extends State<_GuestList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? widget.attendees
        : widget.attendees
              .where(
                (a) =>
                    a.holderName.toLowerCase().contains(q) ||
                    a.ticketId.toLowerCase().contains(q) ||
                    a.tierName.toLowerCase().contains(q),
              )
              .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: TextField(
            key: const ValueKey('guest-search'),
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l.orgSearchGuests,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(t.radii.pill),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: widget.loading
              ? const Center(child: CircularProgressIndicator())
              : shown.isEmpty
              ? Center(
                  child: MessageView(
                    icon: Icons.people_outline_rounded,
                    title: l.orgNoGuests,
                    message: q.isEmpty ? l.orgNoGuestsBody : l.orgNoMatches,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _GuestTile(
                    attendee: shown[i],
                    onCheckIn: () => widget.onCheckIn(shown[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _GuestTile extends StatelessWidget {
  const _GuestTile({required this.attendee, required this.onCheckIn});
  final Attendee attendee;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final a = attendee;
    final Widget trailing;
    if (a.cancelled) {
      trailing = Text(
        l.resCancelled,
        style: context.text.caption.copyWith(color: t.textHint),
      );
    } else if (a.checkedIn) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: t.success, size: 20),
          const SizedBox(width: 4),
          Text(
            formatTime(a.checkedInAt!),
            style: context.text.caption.copyWith(color: t.success),
          ),
        ],
      );
    } else {
      trailing = FilledButton(
        key: ValueKey('guest-checkin-${a.ticketId}'),
        style: FilledButton.styleFrom(
          backgroundColor: t.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onCheckIn,
        child: Text(l.orgCheckInAction),
      );
    }
    return Container(
      key: ValueKey('guest-${a.ticketId}'),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 10, 10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radii.thumbnail),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.bidi(a.holderName),
                  style: context.text.cardTitle.copyWith(
                    fontSize: 15,
                    decoration: a.cancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  context.bidi(a.tierName),
                  style: context.text.caption,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ManualCodeSheet extends StatefulWidget {
  const _ManualCodeSheet();

  @override
  State<_ManualCodeSheet> createState() => _ManualCodeSheetState();
}

class _ManualCodeSheetState extends State<_ManualCodeSheet> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.orgEnterCode, style: context.text.sectionTitle),
          const SizedBox(height: 6),
          Text(l.orgEnterCodeBody, style: context.text.caption),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('manual-code'),
            controller: _c,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(context, v),
            decoration: InputDecoration(
              hintText: l.orgCodeHint,
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton(
              key: const ValueKey('manual-submit'),
              style: FilledButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.pop(context, _c.text),
              child: Text(l.orgVerify),
            ),
          ),
        ],
      ),
    );
  }
}
