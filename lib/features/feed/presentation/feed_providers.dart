import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/feed/domain/smart_feed_scorer.dart';
import 'package:eventra/features/onboarding/domain/interest.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The user's feed inputs: interests, origin (device or home city), saves.
final feedProfileProvider = Provider<FeedProfile>((ref) {
  // Privacy setting: without personalization the feed ignores interests.
  final personalized = ref.watch(
    settingsProvider.select((s) => s.personalizedFeed),
  );
  final interests = personalized
      ? ref.watch(interestsProvider)
      : const <Interest>{};
  final origin = ref.watch(userLocationProvider.select((l) => l.position));
  final now = ref.watch(clockProvider)();
  final savedIds = ref.watch(favoritesProvider);
  final all = ref.watch(eventsProvider).value ?? const <Event>[];
  return FeedProfile(
    origin: origin,
    now: now,
    interests: [
      for (final i in Interest.values)
        if (interests.contains(i)) i,
    ],
    saved: [
      for (final e in all)
        if (savedIds.contains(e.id)) e,
    ],
  );
});
