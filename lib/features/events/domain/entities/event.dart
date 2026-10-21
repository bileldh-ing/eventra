import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class TicketTier with _$TicketTier {
  const factory TicketTier({
    required String id,
    required String name,
    required double price,
    required int capacity,
    required int sold,
    @Default(<String>[]) List<String> perks,
  }) = _TicketTier;
  const TicketTier._();

  factory TicketTier.fromJson(Map<String, dynamic> json) =>
      _$TicketTierFromJson(json);

  int get remaining => (capacity - sold).clamp(0, capacity);
}

@freezed
abstract class Organizer with _$Organizer {
  const factory Organizer({
    required String id,
    required String name,
    required String avatarUrl,
    @Default(false) bool verified,
    @Default(0) int followers,
  }) = _Organizer;

  factory Organizer.fromJson(Map<String, dynamic> json) =>
      _$OrganizerFromJson(json);
}

@freezed
abstract class LineupItem with _$LineupItem {
  const factory LineupItem({required DateTime time, required String title}) =
      _LineupItem;

  factory LineupItem.fromJson(Map<String, dynamic> json) =>
      _$LineupItemFromJson(json);
}

@freezed
abstract class EventReview with _$EventReview {
  const factory EventReview({
    required String author,
    required String avatarUrl,
    required int rating,
    required String text,
    required DateTime date,
  }) = _EventReview;

  factory EventReview.fromJson(Map<String, dynamic> json) =>
      _$EventReviewFromJson(json);
}

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required EventCategory category,
    required String description,
    required DateTime startAt,
    required DateTime endAt,
    required List<TicketTier> tiers,
    required int capacity,
    required int soldCount,
    required String venue,
    required String address,
    required double latitude,
    required double longitude,
    required Organizer organizer,
    required double rating,
    required int reviewCount,
    required int participantsCount,
    required String coverImageUrl,
    required List<String> gallery,
    required String policy,
    @Default(<String>[]) List<String> participantAvatars,
    @Default(<String>[]) List<String> tags,
    @Default(<LineupItem>[]) List<LineupItem> lineup,
    @Default(<EventReview>[]) List<EventReview> reviews,
    String? imageCredit,
  }) = _Event;
  const Event._();

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  /// Headline price shown on cards and details: General Admission when the
  /// event has one, otherwise the cheapest tier.
  double get price {
    for (final t in tiers) {
      if (t.id == 'ga') return t.price;
    }
    return minPrice;
  }

  double get minPrice => tiers.isEmpty
      ? 0
      : tiers.map((t) => t.price).reduce((a, b) => a < b ? a : b);

  bool get isFree => price == 0;

  bool get isSoldOut => tiers.every((t) => t.remaining == 0);
}
