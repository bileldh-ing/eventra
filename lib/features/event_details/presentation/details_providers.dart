import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A toggleable set of ids (followed organizers, waitlisted events).
class IdSetNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Returns true when [id] is now in the set.
  bool toggle(String id) {
    final added = !state.contains(id);
    state = added ? {...state, id} : ({...state}..remove(id));
    return added;
  }
}

/// Organizers the user follows (persisted with the profile in Phase 8).
final followedOrganizersProvider = NotifierProvider<IdSetNotifier, Set<String>>(
  IdSetNotifier.new,
);

/// Sold-out events the user joined the waitlist for.
final waitlistProvider = NotifierProvider<IdSetNotifier, Set<String>>(
  IdSetNotifier.new,
);
