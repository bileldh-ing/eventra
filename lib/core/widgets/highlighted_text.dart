import 'package:eventra/features/search/domain/search_logic.dart';
import 'package:flutter/material.dart';

/// [text] with every case-insensitive occurrence of [query] emphasised.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    required this.query,
    required this.style,
    required this.highlightStyle,
    super.key,
    this.maxLines = 1,
  });

  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final ranges = matchRanges(text, query);
    if (ranges.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    final spans = <TextSpan>[];
    var at = 0;
    for (final (s, e) in ranges) {
      if (s > at) spans.add(TextSpan(text: text.substring(at, s)));
      spans.add(TextSpan(text: text.substring(s, e), style: highlightStyle));
      at = e;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
