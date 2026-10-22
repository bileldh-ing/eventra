import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The eight discovery categories, in chip order.
enum EventCategory {
  cinema(Icons.movie_outlined),
  sports(Icons.sports_basketball_outlined),
  social(Icons.groups_outlined),
  music(Icons.music_note_outlined),
  art(Icons.palette_outlined),
  tech(Icons.memory_outlined),
  food(Icons.restaurant_outlined),
  comedy(Icons.theater_comedy_outlined);

  const EventCategory(this.icon);

  final IconData icon;

  /// Name in the active language.
  String get label {
    final l = AppLocale.l10n;
    return switch (this) {
      cinema => l.catCinema,
      sports => l.catSports,
      social => l.catSocial,
      music => l.catMusic,
      art => l.catArt,
      tech => l.catTech,
      food => l.catFood,
      comedy => l.catComedy,
    };
  }
}
