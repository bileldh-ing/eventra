import 'dart:typed_data';

import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the gradient + icon fallback when the image fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imageProviderFactory.overrideWithValue(
            (url) => MemoryImage(Uint8List.fromList([0, 1, 2, 3])),
          ),
        ],
        child: const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: EventImage(
              url: 'https://example.invalid/x.jpg',
              category: EventCategory.music,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(find.byKey(const ValueKey('image-fallback')), findsOneWidget);
    expect(find.byIcon(EventCategory.music.icon), findsOneWidget);
  });

  test('every category has a distinct fallback gradient', () {
    final gradients = EventCategory.values
        .map((c) => categoryGradient(c).first)
        .toSet();
    expect(gradients.length, EventCategory.values.length);
  });
}
