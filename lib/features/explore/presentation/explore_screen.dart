import 'dart:async';
import 'dart:math' as math;

import 'package:eventra/app/nav.dart';
import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/map/map_layers.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/explore/domain/nearest.dart';
import 'package:eventra/features/explore/presentation/explore_providers.dart';
import 'package:eventra/features/explore/presentation/widgets/explore_widgets.dart';
import 'package:eventra/features/home/presentation/filters_sheet.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

/// Sheet snap points: peek, half (initial, as in the reference) and full.
const kSheetPeek = 0.3;
const kSheetHalf = 0.5;
const kSheetFull = 0.9;

/// Explore tab and per-event map: full CARTO Positron map, floating preview
/// card, pulsing marker and a three-snap "Nearest Location" sheet.
///
/// [focusEventId] preselects an event (the Event Details mini-map opens the
/// map this way); otherwise the nearest event is selected.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.focusEventId});

  final String? focusEventId;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  final _map = MapController();
  final _sheet = DraggableScrollableController();
  final _search = TextEditingController();
  late final AnimationController _fly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  static const _zoom = 14.8;
  String? _selectedId;
  double _sheetSize = kSheetHalf;
  bool _mapReady = false;
  bool _locating = false;
  bool _centered = false;

  // Fly-to interpolation endpoints.
  LatLng? _flyFrom;
  LatLng? _flyTo;
  double _flyFromZoom = _zoom;
  double _flyToZoom = _zoom;
  double _flyDip = 0;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.focusEventId;
    _fly.addListener(_onFlyTick);
  }

  @override
  void dispose() {
    _fly.dispose();
    _sheet.dispose();
    _search.dispose();
    _map.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- camera

  /// Screen y where the focused point should sit: the middle of the map area
  /// left visible between the preview card and the sheet.
  double _focusY(Size size) {
    final top = MediaQuery.paddingOf(context).top + 230;
    final sheetTop = size.height * (1 - _sheetSize);
    return (top + sheetTop) / 2;
  }

  /// Map center that puts [target] at [_focusY] on screen.
  LatLng _centerFor(LatLng target, double zoom) {
    final size = MediaQuery.sizeOf(context);
    const crs = Epsg3857();
    final dy = size.height / 2 - _focusY(size);
    final p = crs.latLngToOffset(target, zoom) + Offset(0, dy);
    return crs.offsetToLatLng(p, zoom);
  }

  void _onFlyTick() {
    final from = _flyFrom;
    final to = _flyTo;
    if (from == null || to == null || !_mapReady) return;
    final t = Curves.easeInOutCubic.transform(_fly.value);
    final lat = from.latitude + (to.latitude - from.latitude) * t;
    final lng = from.longitude + (to.longitude - from.longitude) * t;
    final zoom =
        _flyFromZoom +
        (_flyToZoom - _flyFromZoom) * t -
        _flyDip * math.sin(math.pi * t);
    _map.move(LatLng(lat, lng), zoom);
  }

  /// Smoothly flies the camera so [target] sits above the sheet. Long hops
  /// zoom out a little mid-flight, like a native maps app.
  void _flyToPoint(LatLng target, {double? zoom}) {
    if (!_mapReady) return;
    final camera = _map.camera;
    final endZoom = zoom ?? math.max(camera.zoom, 13.5);
    final end = _centerFor(target, endZoom);
    final km = haversineKm(camera.center, end);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _map.move(end, endZoom);
      return;
    }
    _flyFrom = camera.center;
    _flyTo = end;
    _flyFromZoom = camera.zoom;
    _flyToZoom = endZoom;
    _flyDip = (km / 4).clamp(0.0, 2.5);
    _fly.duration = Duration(
      milliseconds: (600 + km * 25).clamp(600, 1300).round(),
    );
    unawaited(_fly.forward(from: 0));
  }

  /// Keeps the selected marker visible while the sheet is dragged.
  void _onSheetChanged(double size) {
    final before = _sheetSize;
    _sheetSize = size.clamp(kSheetPeek, kSheetFull);
    if (!_mapReady || _fly.isAnimating) return;
    final target = _selectedPoint();
    if (target == null || (before - _sheetSize).abs() < 0.001) return;
    // Do not chase the marker once the sheet covers most of the map.
    if (_sheetSize > 0.7) return;
    _map.move(_centerFor(target, _map.camera.zoom), _map.camera.zoom);
  }

  LatLng? _selectedPoint() {
    final list = ref.read(nearestEventsProvider);
    final sel = _resolveSelected(list);
    return sel?.point;
  }

  NearbyEvent? _resolveSelected(List<NearbyEvent> list) {
    if (list.isEmpty) return null;
    for (final n in list) {
      if (n.event.id == _selectedId) return n;
    }
    return _selectedId == null ? list.first : null;
  }

  /// Centers on the selection (without animation) the first time both the
  /// map and the event list are ready.
  void _centerInitially() {
    if (_centered || !_mapReady) return;
    final target = _selectedPoint();
    if (target == null) return;
    _centered = true;
    _map.move(_centerFor(target, _zoom), _zoom);
  }

  // --------------------------------------------------------------- actions

  void _select(NearbyEvent n) {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _selectedId = n.event.id);
    _flyToPoint(n.point);
  }

  Future<void> _locateMe() async {
    if (_locating) return;
    setState(() => _locating = true);
    final outcome = await ref.read(userLocationProvider.notifier).locate();
    if (!mounted) return;
    setState(() => _locating = false);
    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case LocationOutcome.granted:
        unawaited(HapticFeedback.lightImpact());
        _flyToPoint(ref.read(userLocationProvider).position);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.exploreDistancesUpdated),
            ),
          );
      case LocationOutcome.denied:
      case LocationOutcome.deniedForever:
      case LocationOutcome.serviceDisabled:
      case LocationOutcome.error:
        final label = ref.read(userLocationProvider).label;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              key: const ValueKey('locate-denied'),
              content: Text(
                outcome == LocationOutcome.serviceDisabled
                    ? context.l10n.exploreServicesOff(label)
                    : context.l10n.exploreLocationUnavailable(label),
              ),
            ),
          );
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  /// Continue: opens the selected venue's events. A venue with one event
  /// goes straight to its details.
  void _continue(NearbyEvent? selected) {
    if (selected == null) return;
    final all = ref.read(upcomingEventsProvider).value ?? const <Event>[];
    final atVenue = [
      for (final e in all)
        if (e.venue == selected.event.venue) e,
    ];
    if (atVenue.length <= 1) {
      openEvent(context, selected.event);
      return;
    }
    unawaited(showVenueEventsSheet(context, selected.event.venue, atVenue));
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final list = ref.watch(nearestEventsProvider);
    final user = ref.watch(userLocationProvider);
    final selected = _resolveSelected(list);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final loopsOn = ref.watch(loopingAnimationsProvider);
    if (!_centered && selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centerInitially();
      });
    }

    // First selection once data arrives: center on it without animation.
    final initialTarget = selected?.point ?? user.position;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.tokens.mapBackground,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: FlutterMap(
                  key: const ValueKey('explore-map'),
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: initialTarget,
                    initialZoom: _zoom,
                    minZoom: 3,
                    maxZoom: 19,
                    backgroundColor: context.tokens.mapBackground,
                    onMapReady: () {
                      _mapReady = true;
                      _centerInitially();
                    },
                  ),
                  children: [
                    const PositronTileLayer(),
                    MarkerLayer(
                      markers: [
                        for (final n in list.take(40))
                          if (n.event.id != selected?.event.id)
                            Marker(
                              point: n.point,
                              child: MiniPin(
                                key: ValueKey('pin-${n.event.id}'),
                                onTap: () => _select(n),
                                semanticLabel: n.event.title,
                              ),
                            ),
                        if (user.fromDevice)
                          Marker(
                            point: user.position,
                            width: 28,
                            height: 28,
                            child: const UserLocationDot(),
                          ),
                        if (selected != null)
                          Marker(
                            key: ValueKey(
                              'selected-marker-${selected.event.id}',
                            ),
                            point: selected.point,
                            width: 96,
                            height: 96,
                            child: PulsingMarker(
                              key: ValueKey(
                                'pulse-${selected.event.id}-$loopsOn',
                              ),
                              size: 96,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Top controls.
            PositionedDirectional(
              top: top + 12,
              start: 20,
              end: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MapCircleButton(
                    key: const ValueKey('explore-back'),
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: context.l10n.back,
                    onTap: _back,
                  ),
                  MapCircleButton(
                    key: const ValueKey('locate-me'),
                    icon: Icons.my_location_rounded,
                    semanticLabel: context.l10n.exploreShowMyLocation,
                    busy: _locating,
                    onTap: _locateMe,
                  ),
                ],
              ),
            ),
            // Preview card for the selected event.
            PositionedDirectional(
              top: top + 82,
              start: 20,
              end: 20,
              child: AnimatedSwitcher(
                duration: t.motion.medium,
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -0.08),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: selected == null
                    ? const SizedBox.shrink()
                    : PreviewCard(
                        key: ValueKey('preview-${selected.event.id}'),
                        event: selected.event,
                        onTap: () => openEvent(
                          context,
                          selected.event,
                          heroTag: previewHeroTag(selected.event.id),
                        ),
                      ),
              ),
            ),
            const PositionedDirectional(
              start: 8,
              bottom: 4,
              child: MapAttribution(),
            ),
            // Nearest Location sheet.
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (n) {
                _onSheetChanged(n.extent);
                return false;
              },
              child: DraggableScrollableSheet(
                key: const ValueKey('explore-sheet'),
                controller: _sheet,
                minChildSize: kSheetPeek,
                maxChildSize: kSheetFull,
                snap: true,
                snapSizes: const [kSheetPeek, kSheetHalf, kSheetFull],
                snapAnimationDuration: const Duration(milliseconds: 320),
                builder: (context, scroll) => NearestSheet(
                  scroll: scroll,
                  items: list,
                  selectedId: selected?.event.id,
                  search: _search,
                  bottomPadding: 96 + bottom,
                  onQuery: (q) =>
                      ref.read(exploreQueryProvider.notifier).set(q),
                  onFilters: () => showFiltersSheet(context),
                  onSelect: _select,
                ),
              ),
            ),
            // Continue stays pinned to the bottom of the sheet.
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsetsDirectional.fromSTEB(
                  24,
                  14,
                  24,
                  16 + bottom,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [t.sheet.withValues(alpha: 0), t.sheet],
                    stops: const [0, 0.35],
                  ),
                ),
                child: GradientPillButton(
                  key: const ValueKey('explore-continue'),
                  label: context.l10n.actionContinue,
                  onPressed: selected == null
                      ? null
                      : () => _continue(selected),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String previewHeroTag(String id) => 'preview-$id';

/// Pressable white circle used for the map's back and locate-me buttons.
class MapCircleButton extends StatelessWidget {
  const MapCircleButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    super.key,
    this.busy = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: context.tokens.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.tokens.shadowOr(const Color(0x1A3A2A5A), 0.1),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: busy
              ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: t.primary,
                  ),
                )
              : Icon(icon, color: t.textPrimary, size: 26),
        ),
      ),
    );
  }
}

/// Lists every event at [venue] (Continue on a multi-event venue).
Future<void> showVenueEventsSheet(
  BuildContext context,
  String venue,
  List<Event> events,
) {
  final router = GoRouter.of(context);
  final root = currentTabRoot(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
        child: Column(
          key: const ValueKey('venue-events-sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(venue, style: context.text.sectionTitle),
            const SizedBox(height: 4),
            Text(
              context.l10n.nUpcomingEvents(events.length),
              style: context.text.caption,
            ),
            const SizedBox(height: 12),
            for (final e in events)
              VenueEventTile(
                event: e,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  router.push('$root/event/${e.id}');
                },
              ),
          ],
        ),
      ),
    ),
  );
}
