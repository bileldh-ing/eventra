// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketTier _$TicketTierFromJson(Map<String, dynamic> json) => _TicketTier(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  capacity: (json['capacity'] as num).toInt(),
  sold: (json['sold'] as num).toInt(),
  perks:
      (json['perks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$TicketTierToJson(_TicketTier instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'capacity': instance.capacity,
      'sold': instance.sold,
      'perks': instance.perks,
    };

_Organizer _$OrganizerFromJson(Map<String, dynamic> json) => _Organizer(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String,
  verified: json['verified'] as bool? ?? false,
  followers: (json['followers'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrganizerToJson(_Organizer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'verified': instance.verified,
      'followers': instance.followers,
    };

_LineupItem _$LineupItemFromJson(Map<String, dynamic> json) => _LineupItem(
  time: DateTime.parse(json['time'] as String),
  title: json['title'] as String,
);

Map<String, dynamic> _$LineupItemToJson(_LineupItem instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'title': instance.title,
    };

_EventReview _$EventReviewFromJson(Map<String, dynamic> json) => _EventReview(
  author: json['author'] as String,
  avatarUrl: json['avatarUrl'] as String,
  rating: (json['rating'] as num).toInt(),
  text: json['text'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$EventReviewToJson(_EventReview instance) =>
    <String, dynamic>{
      'author': instance.author,
      'avatarUrl': instance.avatarUrl,
      'rating': instance.rating,
      'text': instance.text,
      'date': instance.date.toIso8601String(),
    };

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  title: json['title'] as String,
  category: $enumDecode(_$EventCategoryEnumMap, json['category']),
  description: json['description'] as String,
  startAt: DateTime.parse(json['startAt'] as String),
  endAt: DateTime.parse(json['endAt'] as String),
  tiers: (json['tiers'] as List<dynamic>)
      .map((e) => TicketTier.fromJson(e as Map<String, dynamic>))
      .toList(),
  capacity: (json['capacity'] as num).toInt(),
  soldCount: (json['soldCount'] as num).toInt(),
  venue: json['venue'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>),
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  participantsCount: (json['participantsCount'] as num).toInt(),
  coverImageUrl: json['coverImageUrl'] as String,
  gallery: (json['gallery'] as List<dynamic>).map((e) => e as String).toList(),
  policy: json['policy'] as String,
  participantAvatars:
      (json['participantAvatars'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  lineup:
      (json['lineup'] as List<dynamic>?)
          ?.map((e) => LineupItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LineupItem>[],
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map((e) => EventReview.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EventReview>[],
  imageCredit: json['imageCredit'] as String?,
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': _$EventCategoryEnumMap[instance.category]!,
  'description': instance.description,
  'startAt': instance.startAt.toIso8601String(),
  'endAt': instance.endAt.toIso8601String(),
  'tiers': instance.tiers.map((e) => e.toJson()).toList(),
  'capacity': instance.capacity,
  'soldCount': instance.soldCount,
  'venue': instance.venue,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'organizer': instance.organizer.toJson(),
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'participantsCount': instance.participantsCount,
  'coverImageUrl': instance.coverImageUrl,
  'gallery': instance.gallery,
  'policy': instance.policy,
  'participantAvatars': instance.participantAvatars,
  'tags': instance.tags,
  'lineup': instance.lineup.map((e) => e.toJson()).toList(),
  'reviews': instance.reviews.map((e) => e.toJson()).toList(),
  'imageCredit': instance.imageCredit,
};

const _$EventCategoryEnumMap = {
  EventCategory.cinema: 'cinema',
  EventCategory.sports: 'sports',
  EventCategory.social: 'social',
  EventCategory.music: 'music',
  EventCategory.art: 'art',
  EventCategory.tech: 'tech',
  EventCategory.food: 'food',
  EventCategory.comedy: 'comedy',
};
