import 'package:flutter/material.dart';

/// Avatar background choices for initials avatars.
const kAvatarColors = <Color>[
  Color(0xFFBC47F5),
  Color(0xFF6C63FF),
  Color(0xFF2EA6F2),
  Color(0xFF22C55E),
  Color(0xFFF6A15B),
  Color(0xFFEF4466),
];

/// Editable profile details. The name lives on the account row; the rest
/// in the `profiles` table.
@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    this.bio = '',
    this.city = '',
    this.avatarColor = 0,
  });

  final String name;
  final String bio;
  final String city;

  /// Index into [kAvatarColors].
  final int avatarColor;

  Color get color => kAvatarColors[avatarColor % kAvatarColors.length];

  /// Up to two initials ("Daniel Brooks" -> "DB").
  String get initials => initialsOf(name);

  UserProfile copyWith({
    String? name,
    String? bio,
    String? city,
    int? avatarColor,
  }) => UserProfile(
    name: name ?? this.name,
    bio: bio ?? this.bio,
    city: city ?? this.city,
    avatarColor: avatarColor ?? this.avatarColor,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.name == name &&
      other.bio == bio &&
      other.city == city &&
      other.avatarColor == avatarColor;

  @override
  int get hashCode => Object.hash(name, bio, city, avatarColor);
}

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  final letters = [
    for (final p in parts.take(2)) p.characters.first.toUpperCase(),
  ];
  return letters.join();
}

/// Validation for the edit form. Returns an error message or null.
abstract final class ProfileValidators {
  static const maxBio = 160;
  static const maxCity = 60;

  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.length < 2) return 'Enter your name (2+ characters)';
    if (s.length > 50) return 'Keep it under 50 characters';
    return null;
  }

  static String? bio(String? v) => (v?.trim().length ?? 0) > maxBio
      ? 'Keep it under $maxBio characters'
      : null;

  static String? city(String? v) => (v?.trim().length ?? 0) > maxCity
      ? 'Keep it under $maxCity characters'
      : null;
}
