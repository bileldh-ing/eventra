import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:latlong2/latlong.dart';

/// Parsed seed file.
class SeedBundle {
  const SeedBundle({
    required this.generatedAt,
    required this.defaultLocation,
    required this.defaultLocationName,
    required this.events,
  });

  /// Organizers are stored once in the seed and joined into each event here.
  factory SeedBundle.fromJson(Map<String, dynamic> json) {
    final organizers = {
      for (final o in (json['organizers'] as List).cast<Map<String, dynamic>>())
        o['id'] as String: o,
    };
    final loc = json['defaultLocation'] as Map<String, dynamic>;
    return SeedBundle(
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      defaultLocation: LatLng(
        (loc['latitude'] as num).toDouble(),
        (loc['longitude'] as num).toDouble(),
      ),
      defaultLocationName: loc['name'] as String,
      events: [
        for (final e in (json['events'] as List).cast<Map<String, dynamic>>())
          Event.fromJson({...e, 'organizer': organizers[e['organizerId']]}),
      ],
    );
  }

  final DateTime generatedAt;
  final LatLng defaultLocation;
  final String defaultLocationName;
  final List<Event> events;
}
