import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/widgets/share_event.dart';
import 'package:flutter/material.dart';

/// Fictional attendee names paired with the placeholder avatars.
const _names = [
  'Sarah Miller',
  'Liam Carter',
  'Noah Kim',
  'Emma Davis',
  'Ava Thompson',
  'Mason Lee',
];

/// Number of friends shown first (demo social graph).
const kDemoFriendsGoing = 2;

Future<void> showParticipantsSheet(BuildContext context, Event event) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => ParticipantsSheet(event: event),
  );
}

class ParticipantsSheet extends StatelessWidget {
  const ParticipantsSheet({required this.event, super.key});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final avatars = event.participantAvatars;
    final others = event.participantsCount - avatars.length;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                '${event.participantsCount} Participants',
                style: EventraText.sectionTitle,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: avatars.length,
                itemBuilder: (context, i) {
                  final friend = i < kDemoFriendsGoing;
                  return ListTile(
                    leading: NetAvatar(
                      url: avatars[i],
                      size: 44,
                      borderWidth: 0,
                      name: _names[i % _names.length],
                    ),
                    title: Text(
                      _names[i % _names.length],
                      style: EventraText.body.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      friend ? 'Friend - going' : 'Going',
                      style: EventraText.caption,
                    ),
                    trailing: friend
                        ? Icon(Icons.favorite_rounded, color: t.primary)
                        : null,
                  );
                },
              ),
            ),
            if (others > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: Text(
                  '+$others more people are going',
                  style: EventraText.caption,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: GradientPillButton(
                label: 'Invite friends',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () => shareInvite(event),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
