import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Glass bookmark circle that toggles the favorite with a pop animation.
class BookmarkButton extends ConsumerStatefulWidget {
  const BookmarkButton({
    required this.eventId,
    super.key,
    this.size = 40,
    this.iconSize = 20,
  });

  final String eventId;
  final double size;
  final double iconSize;

  @override
  ConsumerState<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.35), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.35, end: 1), weight: 65),
  ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    _pop.forward(from: 0);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failed = context.l10n.favUpdateFailed;
    final saved = await ref
        .read(favoritesProvider.notifier)
        .toggle(widget.eventId);
    if (saved == null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(failed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(isFavoriteProvider(widget.eventId));
    return ScaleTransition(
      scale: _scale,
      child: GlassCircleButton(
        key: ValueKey('bookmark-${widget.eventId}'),
        icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        semanticLabel: saved ? context.l10n.favRemove : context.l10n.favSave,
        size: widget.size,
        iconSize: widget.iconSize,
        onPressed: _toggle,
      ),
    );
  }
}
