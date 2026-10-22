import 'package:eventra/app/auth_guard.dart';
import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/onboarding/domain/home_city.dart';
import 'package:eventra/features/onboarding/presentation/onboarding_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

/// Last onboarding step: allow location (picks the nearest covered city) or
/// choose a city by hand, then Home.
class LocationSetupScreen extends ConsumerStatefulWidget {
  const LocationSetupScreen({super.key, this.from});
  final String? from;

  @override
  ConsumerState<LocationSetupScreen> createState() =>
      _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  late HomeCity? _city = ref.read(homeCityProvider);
  bool _locating = false;
  String? _note;

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _note = null;
    });
    final r = await ref.read(locationServiceProvider).current();
    if (!mounted) return;
    setState(() {
      _locating = false;
      final p = r.position;
      if (r.outcome == LocationOutcome.granted && p != null) {
        _city = sortByDistance(
          kHomeCities,
          p,
          (c) => LatLng(c.lat, c.lng),
        ).first;
        _note = context.l10n.locNearestArea(_city!.label);
      } else {
        _note = context.l10n.locOff;
      }
    });
  }

  Future<void> _continue() async {
    if (_city != null) await ref.read(homeCityProvider.notifier).choose(_city!);
    if (mounted) context.go(safeFrom(widget.from) ?? '/home');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          FacetedGradient(
            gradient: t.headerGradient,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(t.radii.header),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24, pad.top + 28, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.locWhere, style: context.text.heroTitle),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.locWhy,
                    style: context.text.body.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Pressable(
                    key: const ValueKey('location-use-gps'),
                    onTap: _locating ? null : _locate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(t.radii.pill),
                        boxShadow: t.softShadow,
                      ),
                      child: Row(
                        children: [
                          if (_locating)
                            SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: t.primary,
                              ),
                            )
                          else
                            Icon(Icons.my_location_rounded, color: t.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.l10n.locUseCurrent,
                              style: context.text.cardTitle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: t.textHint),
                        ],
                      ),
                    ),
                  ),
                  if (_note != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _note!,
                      key: const ValueKey('location-note'),
                      style: context.text.caption.copyWith(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 12),
              itemCount: kHomeCities.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = kHomeCities[i];
                final selected = c == _city;
                return Pressable(
                  key: ValueKey('city-${c.name}'),
                  onTap: () => setState(() => _city = c),
                  child: Semantics(
                    selected: selected,
                    button: true,
                    child: AnimatedContainer(
                      duration: t.motion.fast,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(t.radii.thumbnail),
                        border: Border.all(
                          color: selected ? t.primary : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: t.softShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: t.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_city_rounded,
                              color: t.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              c.label,
                              style: context.text.cardTitle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: selected ? 1 : 0,
                            duration: t.motion.fast,
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: t.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 4, 24, pad.bottom + 16),
            child: Column(
              children: [
                GradientPillButton(
                  key: const ValueKey('location-continue'),
                  label: context.l10n.actionContinue,
                  onPressed: _city == null ? null : _continue,
                ),
                AuthLinkButton(
                  key: const ValueKey('location-skip'),
                  label: context.l10n.locSkip,
                  bold: false,
                  onPressed: () => context.go(safeFrom(widget.from) ?? '/home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
