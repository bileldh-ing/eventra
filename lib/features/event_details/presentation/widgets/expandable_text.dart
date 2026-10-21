import 'package:flutter/material.dart';

/// Text clamped to [maxLines] that ends with a bold inline "See more....".
/// Expanding animates the height change.
class ExpandableText extends StatefulWidget {
  const ExpandableText({
    required this.text,
    required this.style,
    super.key,
    this.maxLines = 3,
    this.moreLabel = 'See more....',
    this.lessLabel = 'See less',
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final String moreLabel;
  final String lessLabel;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  /// Longest prefix that, with the inline link, fits in `maxLines`.
  String _clamp(double width, TextStyle linkStyle, TextScaler scaler) {
    final dir = Directionality.of(context);
    bool fits(String prefix) {
      final p = TextPainter(
        text: TextSpan(
          style: widget.style,
          children: [
            TextSpan(text: prefix),
            TextSpan(text: ' ${widget.moreLabel}', style: linkStyle),
          ],
        ),
        textDirection: dir,
        textScaler: scaler,
        maxLines: widget.maxLines,
      )..layout(maxWidth: width);
      final over = p.didExceedMaxLines;
      p.dispose();
      return !over;
    }

    if (fits(widget.text)) return widget.text;
    var lo = 0;
    var hi = widget.text.length;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (fits(widget.text.substring(0, mid))) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    final cut = widget.text.substring(0, lo);
    final space = cut.lastIndexOf(' ');
    return (space > 0 ? cut.substring(0, space) : cut).trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = widget.style.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A1530),
    );
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, c) {
        final clamped = _clamp(c.maxWidth, linkStyle, scaler);
        final truncated = clamped.length < widget.text.length;
        return AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            key: const ValueKey('about-text'),
            onTap: truncated
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Text.rich(
              TextSpan(
                style: widget.style,
                children: [
                  TextSpan(text: _expanded ? widget.text : clamped),
                  if (truncated)
                    TextSpan(
                      text: _expanded
                          ? ' ${widget.lessLabel}'
                          : ' ${widget.moreLabel}',
                      style: linkStyle,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
