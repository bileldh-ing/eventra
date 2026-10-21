import 'package:flutter/material.dart';

/// The eight discovery categories, in chip order.
enum EventCategory {
  cinema('Cinema', Icons.movie_outlined),
  sports('Sports', Icons.sports_basketball_outlined),
  social('Social', Icons.groups_outlined),
  music('Music', Icons.music_note_outlined),
  art('Art', Icons.palette_outlined),
  tech('Tech', Icons.memory_outlined),
  food('Food', Icons.restaurant_outlined),
  comedy('Comedy', Icons.theater_comedy_outlined);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}
