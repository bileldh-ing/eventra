import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Basemap configuration. The app ships a keyless light-gray look: standard
/// OpenStreetMap tiles drawn through a grayscale "Positron" color filter.
/// CARTO's keyless raster endpoint now serves an "API KEY REQUIRED"
/// watermark, so [MapStyle.cartoPositron] is kept for builds with a CARTO
/// key (swap it in via [mapStyleProvider]).
class MapStyle {
  const MapStyle({
    required this.urlTemplate,
    required this.attribution,
    this.subdomains = const [],
    this.colorFilter,
    this.maxNativeZoom = 19,
  });

  /// OSM tiles + grayscale filter (default, no API key).
  static const osmPositron = MapStyle(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
    colorFilter: kPositronFilter,
  );

  /// CARTO Positron (needs a CARTO API key in production).
  static const cartoPositron = MapStyle(
    urlTemplate: kCartoPositronUrl,
    attribution: '© OpenStreetMap contributors © CARTO',
    subdomains: ['a', 'b', 'c', 'd'],
    maxNativeZoom: 20,
  );

  final String urlTemplate;
  final String attribution;
  final List<String> subdomains;
  final ColorFilter? colorFilter;
  final int maxNativeZoom;
}

const kCartoPositronUrl =
    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

/// Luminance grayscale, lifted toward white: light background, white roads,
/// mid-gray labels, like the reference's light-gray map.
const kPositronFilter = ColorFilter.matrix(<double>[
  0.149, 0.501, 0.051, 0, 75, //
  0.149, 0.501, 0.051, 0, 75,
  0.149, 0.501, 0.051, 0, 75,
  0, 0, 0, 1, 0,
]);

/// Dark-mode basemap: the same luminance, inverted and compressed into a
/// deep aubergine range (land ~#1D1A2B, roads a touch darker, labels light
/// gray), so maps sit quietly under the dark palette instead of glaring.
const kPositronDarkFilter = ColorFilter.matrix(<double>[
  -0.179, -0.352, -0.068, 0, 177, //
  -0.179, -0.352, -0.068, 0, 171,
  -0.179, -0.352, -0.068, 0, 186,
  0, 0, 0, 1, 0,
]);

final mapStyleProvider = Provider<MapStyle>((ref) => MapStyle.osmPositron);

/// Tile source. Tests override it with bundled fixture tiles.
final mapTileProviderProvider = Provider<TileProvider>(
  (ref) => NetworkTileProvider(),
);

/// Looping animations (map pulse) can be disabled for tests and goldens; the
/// platform reduce-motion setting is always respected too.
final loopingAnimationsProvider = Provider<bool>((ref) => true);

/// The light-gray basemap tile layer used by every map in the app.
class PositronTileLayer extends ConsumerWidget {
  const PositronTileLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(mapStyleProvider);
    final filter = context.tokens.isDark
        ? kPositronDarkFilter
        : style.colorFilter;
    return TileLayer(
      urlTemplate: style.urlTemplate,
      subdomains: style.subdomains,
      userAgentPackageName: 'com.eventra.app',
      tileProvider: ref.watch(mapTileProviderProvider),
      maxNativeZoom: style.maxNativeZoom,
      tileBuilder: filter == null
          ? null
          : (context, tile, _) =>
                ColorFiltered(colorFilter: filter, child: tile),
    );
  }
}

/// Small attribution label shown on every map.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.tokens.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Consumer(
          builder: (context, ref, _) => Text(
            ref.watch(mapStyleProvider).attribution,
            style: context.text.caption.copyWith(fontSize: 9),
          ),
        ),
      ),
    );
  }
}

/// Solid purple dot with a soft, looping ripple halo.
class PulsingMarker extends ConsumerStatefulWidget {
  const PulsingMarker({super.key, this.size = 64, this.color});

  final double size;
  final Color? color;

  @override
  ConsumerState<PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends ConsumerState<PulsingMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate =
        ref.read(loopingAnimationsProvider) &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (animate && !_c.isAnimating) {
      _c.repeat();
    } else if (!animate) {
      _c
        ..stop()
        ..value = 0.55;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.tokens.primary;
    return Semantics(
      label: context.l10n.mapEventLocation,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _PulsePainter(progress: _c.value, color: color),
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.width / 2;
    // Static soft halo, as in the reference.
    canvas
      ..drawCircle(
        c,
        maxR * 0.62,
        Paint()..color = color.withValues(alpha: 0.18),
      )
      // Expanding ripple.
      ..drawCircle(
        c,
        maxR * (0.3 + 0.7 * progress),
        Paint()..color = color.withValues(alpha: 0.28 * (1 - progress)),
      )
      ..drawCircle(c, 9, Paint()..color = Colors.white)
      ..drawCircle(c, 6.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PulsePainter old) =>
      old.progress != progress || old.color != color;
}

/// Blue "you are here" dot.
class UserLocationDot extends StatelessWidget {
  const UserLocationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('user-dot'),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Color(0x553B82F6), blurRadius: 12)],
      ),
    );
  }
}
