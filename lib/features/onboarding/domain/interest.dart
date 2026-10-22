import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// What the user is into. Each interest maps onto the catalogue categories
/// that the smart feed rewards.
enum Interest {
  music(Icons.music_note_outlined, {EventCategory.music}),
  cinema(Icons.movie_outlined, {EventCategory.cinema}),
  sports(Icons.sports_basketball_outlined, {EventCategory.sports}),
  social(Icons.groups_outlined, {EventCategory.social}),
  art(Icons.palette_outlined, {EventCategory.art}),
  tech(Icons.memory_outlined, {EventCategory.tech}),
  food(Icons.restaurant_outlined, {EventCategory.food}),
  comedy(Icons.theater_comedy_outlined, {EventCategory.comedy}),
  outdoors(Icons.landscape_outlined, {
    EventCategory.sports,
    EventCategory.food,
  }),
  nightlife(Icons.nightlife_outlined, {
    EventCategory.music,
    EventCategory.social,
  }),
  charity(Icons.volunteer_activism_outlined, {
    EventCategory.social,
  }),
  business(Icons.work_outline_rounded, {EventCategory.tech});

  const Interest(this.icon, this.categories);

  /// Name in the active language.
  String get label {
    final l = AppLocale.l10n;
    return switch (this) {
      music => l.catMusic,
      cinema => l.catCinema,
      sports => l.catSports,
      social => l.catSocial,
      art => l.catArt,
      tech => l.catTech,
      food => l.catFood,
      comedy => l.catComedy,
      outdoors => l.intOutdoors,
      nightlife => l.intNightlife,
      charity => l.intCharity,
      business => l.intBusiness,
    };
  }

  final IconData icon;
  final Set<EventCategory> categories;

  static const minimum = 3;

  static Interest? byName(String name) {
    for (final i in values) {
      if (i.name == name) return i;
    }
    return null;
  }
}

/// Categories rewarded by a set of interests, in interest order.
List<EventCategory> categoriesFor(Iterable<Interest> interests) {
  final out = <EventCategory>[];
  for (final i in interests) {
    for (final c in i.categories) {
      if (!out.contains(c)) out.add(c);
    }
  }
  return out;
}
