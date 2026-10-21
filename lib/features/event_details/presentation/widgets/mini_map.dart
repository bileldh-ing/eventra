import 'package:eventra/core/map/map_layers.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

Uri directionsUri(Event e) => Uri.parse(
  'https://www.google.com/maps/dir/?api=1&destination=${e.latitude},${e.longitude}',
);

/// Rounded, non-interactive Positron map with the pulsing marker. Tap opens
/// the full map; long-press opens directions in the maps app.
class MiniMapCard extends StatelessWidget {
  const MiniMapCard({required this.event, required this.onOpen, super.key});

  final Event event;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final point = LatLng(event.latitude, event.longitude);
    return Semantics(
      button: true,
      label: 'Open map for ${event.venue}. Long press for directions.',
      child: GestureDetector(
        key: const ValueKey('mini-map'),
        onTap: onOpen,
        onLongPress: () => launchUrl(
          directionsUri(event),
          mode: LaunchMode.externalApplication,
        ),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.radii.miniMap),
            boxShadow: t.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(t.radii.miniMap),
            child: RepaintBoundary(
              child: Stack(
                children: [
                  AbsorbPointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 15,
                        backgroundColor: const Color(0xFFF2F2F0),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        const PositronTileLayer(),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: point,
                              width: 72,
                              height: 72,
                              child: const PulsingMarker(size: 72),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 8,
                    bottom: 6,
                    child: MapAttribution(),
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
