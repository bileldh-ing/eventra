import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:meta/meta.dart';

/// Steps of the create/edit-event wizard, in order.
enum WizardStep { basics, schedule, venue, tiers, cover, review }

/// One ticket tier being edited. Money is integer cents.
@immutable
class DraftTier {
  const DraftTier({
    required this.id,
    this.name = '',
    this.priceCents = 0,
    this.capacity = 0,
    this.sold = 0,
  });

  factory DraftTier.fromJson(Map<String, dynamic> j) => DraftTier(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    priceCents: j['priceCents'] as int? ?? 0,
    capacity: j['capacity'] as int? ?? 0,
    sold: j['sold'] as int? ?? 0,
  );

  final String id;
  final String name;
  final int priceCents;
  final int capacity;

  /// Seats already sold (editing a published event): capacity can not go
  /// below this.
  final int sold;

  DraftTier copyWith({String? name, int? priceCents, int? capacity}) =>
      DraftTier(
        id: id,
        name: name ?? this.name,
        priceCents: priceCents ?? this.priceCents,
        capacity: capacity ?? this.capacity,
        sold: sold,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'priceCents': priceCents,
    'capacity': capacity,
    'sold': sold,
  };

  @override
  bool operator ==(Object other) =>
      other is DraftTier &&
      other.id == id &&
      other.name == name &&
      other.priceCents == priceCents &&
      other.capacity == capacity &&
      other.sold == sold;

  @override
  int get hashCode => Object.hash(id, name, priceCents, capacity, sold);
}

/// An event being created or edited. Every field is optional until the
/// matching wizard step validates it, so a half-filled draft can be saved.
@immutable
class EventDraft {
  const EventDraft({
    required this.id,
    this.eventId,
    this.title = '',
    this.category,
    this.description = '',
    this.startAt,
    this.endAt,
    this.venue = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.tiers = const [DraftTier(id: 't1')],
    this.coverUrl,
    this.updatedAt,
  });

  /// Prefills the wizard from an event the organizer already published.
  factory EventDraft.fromEvent(Event e, {required String draftId}) =>
      EventDraft(
        id: draftId,
        eventId: e.id,
        title: e.title,
        category: e.category,
        description: e.description,
        startAt: e.startAt,
        endAt: e.endAt,
        venue: e.venue,
        address: e.address,
        latitude: e.latitude,
        longitude: e.longitude,
        tiers: [
          for (final t in e.tiers)
            DraftTier(
              id: t.id,
              name: t.name,
              priceCents: (t.price * 100).round(),
              capacity: t.capacity,
              sold: t.sold,
            ),
        ],
        coverUrl: e.coverImageUrl,
      );

  factory EventDraft.fromJson(Map<String, dynamic> j) {
    DateTime? date(String k) =>
        j[k] == null ? null : DateTime.parse(j[k] as String);
    return EventDraft(
      id: j['id'] as String,
      eventId: j['eventId'] as String?,
      title: j['title'] as String? ?? '',
      category: j['category'] == null
          ? null
          : EventCategory.values.byName(j['category'] as String),
      description: j['description'] as String? ?? '',
      startAt: date('startAt'),
      endAt: date('endAt'),
      venue: j['venue'] as String? ?? '',
      address: j['address'] as String? ?? '',
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      tiers: [
        for (final t in (j['tiers'] as List? ?? const []))
          DraftTier.fromJson((t as Map).cast<String, dynamic>()),
      ],
      coverUrl: j['coverUrl'] as String?,
      updatedAt: date('updatedAt'),
    );
  }

  final String id;

  /// The published event this draft edits, or null for a new event.
  final String? eventId;
  final String title;
  final EventCategory? category;
  final String description;
  final DateTime? startAt;
  final DateTime? endAt;
  final String venue;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<DraftTier> tiers;
  final String? coverUrl;
  final DateTime? updatedAt;

  bool get isEdit => eventId != null;
  bool get hasPin => latitude != null && longitude != null;
  int get totalCapacity => tiers.fold(0, (s, t) => s + t.capacity);

  static const _keep = Object();

  EventDraft copyWith({
    String? title,
    Object? category = _keep,
    String? description,
    Object? startAt = _keep,
    Object? endAt = _keep,
    String? venue,
    String? address,
    Object? latitude = _keep,
    Object? longitude = _keep,
    List<DraftTier>? tiers,
    Object? coverUrl = _keep,
    DateTime? updatedAt,
  }) => EventDraft(
    id: id,
    eventId: eventId,
    title: title ?? this.title,
    category: identical(category, _keep)
        ? this.category
        : category as EventCategory?,
    description: description ?? this.description,
    startAt: identical(startAt, _keep) ? this.startAt : startAt as DateTime?,
    endAt: identical(endAt, _keep) ? this.endAt : endAt as DateTime?,
    venue: venue ?? this.venue,
    address: address ?? this.address,
    latitude: identical(latitude, _keep) ? this.latitude : latitude as double?,
    longitude: identical(longitude, _keep)
        ? this.longitude
        : longitude as double?,
    tiers: tiers ?? this.tiers,
    coverUrl: identical(coverUrl, _keep) ? this.coverUrl : coverUrl as String?,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'title': title,
    'category': category?.name,
    'description': description,
    'startAt': startAt?.toIso8601String(),
    'endAt': endAt?.toIso8601String(),
    'venue': venue,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'tiers': [for (final t in tiers) t.toJson()],
    'coverUrl': coverUrl,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// The event attendees will see once this draft is published.
  Event toEvent({
    required String eventId,
    required Organizer organizer,
    required String policy,
    Event? previous,
  }) {
    final tierList = [
      for (final t in tiers)
        TicketTier(
          id: t.id,
          name: t.name.trim(),
          price: t.priceCents / 100,
          capacity: t.capacity,
          sold: t.sold,
        ),
    ];
    return Event(
      id: eventId,
      title: title.trim(),
      category: category!,
      description: description.trim(),
      startAt: startAt!,
      endAt: endAt!,
      tiers: tierList,
      capacity: totalCapacity,
      soldCount: tiers.fold(0, (s, t) => s + t.sold),
      venue: venue.trim(),
      address: address.trim(),
      latitude: latitude!,
      longitude: longitude!,
      organizer: organizer,
      rating: previous?.rating ?? 0,
      reviewCount: previous?.reviewCount ?? 0,
      participantsCount: previous?.participantsCount ?? 0,
      coverImageUrl: coverUrl!,
      gallery: [coverUrl!],
      policy: previous?.policy ?? policy,
      participantAvatars: previous?.participantAvatars ?? const [],
      tags: const ['organizer', 'ticketed'],
      lineup: previous?.lineup ?? const [],
      reviews: previous?.reviews ?? const [],
    );
  }
}

/// Why a wizard field is not acceptable yet. Messages are localized in the
/// presentation layer.
enum DraftIssue {
  titleLength,
  categoryMissing,
  descriptionLength,
  startMissing,
  startInPast,
  endMissing,
  endBeforeStart,
  tooLong,
  venueLength,
  addressLength,
  pinMissing,
  tiersCount,
  tierName,
  tierNameDuplicate,
  tierPrice,
  tierCapacity,
  tierBelowSold,
  coverMissing,
}

/// A problem on one field; [tier] is the tier index for tier issues.
@immutable
class DraftError {
  const DraftError(this.issue, {this.tier});
  final DraftIssue issue;
  final int? tier;

  @override
  bool operator ==(Object other) =>
      other is DraftError && other.issue == issue && other.tier == tier;

  @override
  int get hashCode => Object.hash(issue, tier);

  @override
  String toString() => 'DraftError($issue${tier == null ? '' : ', $tier'})';
}

/// Wizard validation rules, per step. Pure, so they are unit-tested.
abstract final class DraftValidator {
  static const titleMin = 3;
  static const titleMax = 80;
  static const descriptionMin = 20;
  static const descriptionMax = 2000;
  static const venueMin = 2;
  static const venueMax = 80;
  static const addressMin = 3;
  static const addressMax = 120;
  static const tierNameMin = 2;
  static const tierNameMax = 30;
  static const maxTiers = 5;
  static const maxPriceCents = 1000000; // $10,000
  static const maxCapacity = 100000;
  static const maxDuration = Duration(days: 7);

  static List<DraftError> step(
    WizardStep step,
    EventDraft d, {
    required DateTime now,
  }) => switch (step) {
    WizardStep.basics => _basics(d),
    WizardStep.schedule => _schedule(d, now),
    WizardStep.venue => _venue(d),
    WizardStep.tiers => _tiers(d),
    WizardStep.cover => [
      if (d.coverUrl == null || d.coverUrl!.isEmpty)
        const DraftError(DraftIssue.coverMissing),
    ],
    WizardStep.review => all(d, now: now),
  };

  /// Every problem in the draft (the review step and publish).
  static List<DraftError> all(EventDraft d, {required DateTime now}) => [
    for (final s in WizardStep.values)
      if (s != WizardStep.review) ...step(s, d, now: now),
  ];

  /// The first step with a problem, or null when the draft can publish.
  static WizardStep? firstInvalidStep(EventDraft d, {required DateTime now}) {
    for (final s in WizardStep.values) {
      if (s == WizardStep.review) continue;
      if (step(s, d, now: now).isNotEmpty) return s;
    }
    return null;
  }

  static List<DraftError> _basics(EventDraft d) {
    final title = d.title.trim().length;
    final desc = d.description.trim().length;
    return [
      if (title < titleMin || title > titleMax)
        const DraftError(DraftIssue.titleLength),
      if (d.category == null) const DraftError(DraftIssue.categoryMissing),
      if (desc < descriptionMin || desc > descriptionMax)
        const DraftError(DraftIssue.descriptionLength),
    ];
  }

  static List<DraftError> _schedule(EventDraft d, DateTime now) {
    final start = d.startAt;
    final end = d.endAt;
    return [
      if (start == null) const DraftError(DraftIssue.startMissing),
      // A published event keeps its date when only its tiers are edited.
      if (start != null && !d.isEdit && !start.isAfter(now))
        const DraftError(DraftIssue.startInPast),
      if (end == null) const DraftError(DraftIssue.endMissing),
      if (start != null && end != null && !end.isAfter(start))
        const DraftError(DraftIssue.endBeforeStart),
      if (start != null &&
          end != null &&
          end.isAfter(start) &&
          end.difference(start) > maxDuration)
        const DraftError(DraftIssue.tooLong),
    ];
  }

  static List<DraftError> _venue(EventDraft d) {
    final venue = d.venue.trim().length;
    final address = d.address.trim().length;
    return [
      if (venue < venueMin || venue > venueMax)
        const DraftError(DraftIssue.venueLength),
      if (address < addressMin || address > addressMax)
        const DraftError(DraftIssue.addressLength),
      if (!d.hasPin) const DraftError(DraftIssue.pinMissing),
    ];
  }

  static List<DraftError> _tiers(EventDraft d) {
    final errors = <DraftError>[];
    if (d.tiers.isEmpty || d.tiers.length > maxTiers) {
      errors.add(const DraftError(DraftIssue.tiersCount));
    }
    final seen = <String>{};
    for (var i = 0; i < d.tiers.length; i++) {
      final t = d.tiers[i];
      final name = t.name.trim();
      if (name.length < tierNameMin || name.length > tierNameMax) {
        errors.add(DraftError(DraftIssue.tierName, tier: i));
      } else if (!seen.add(name.toLowerCase())) {
        errors.add(DraftError(DraftIssue.tierNameDuplicate, tier: i));
      }
      if (t.priceCents < 0 || t.priceCents > maxPriceCents) {
        errors.add(DraftError(DraftIssue.tierPrice, tier: i));
      }
      if (t.capacity < 1 || t.capacity > maxCapacity) {
        errors.add(DraftError(DraftIssue.tierCapacity, tier: i));
      } else if (t.capacity < t.sold) {
        errors.add(DraftError(DraftIssue.tierBelowSold, tier: i));
      }
    }
    return errors;
  }
}

/// Parses a price typed by the organizer ('12', '12.5', '12,50') into
/// cents; null when it is not a valid non-negative amount.
int? parsePriceCents(String input) {
  final s = input.trim().replaceAll(',', '.');
  if (s.isEmpty) return 0;
  final m = RegExp(r'^(\d{1,7})(?:\.(\d{1,2}))?$').firstMatch(s);
  if (m == null) return null;
  final whole = int.parse(m.group(1)!);
  final frac = (m.group(2) ?? '').padRight(2, '0');
  return whole * 100 + int.parse(frac);
}

/// Cover photos organizers can pick from (the catalogue's own licensed
/// set, cached like every other event image).
const kCoverChoices = <String>[
  'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=1200&q=80&fm=jpg&fit=crop',
  'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=1200&q=80&fm=jpg&fit=crop',
  'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=1200&q=80&fm=jpg&fit=crop',
  'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1200&q=80&fm=jpg&fit=crop',
  'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=1200&q=80&fm=jpg&fit=crop',
  'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=1200&q=80&fm=jpg&fit=crop',
];
