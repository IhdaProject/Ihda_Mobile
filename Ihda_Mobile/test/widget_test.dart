import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihda_mobile/app/app.dart';

void main() {
  testWidgets('NamazTimingApp renders successfully smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(const ProviderScope(child: NamazTimingApp()));

    // Verify initial loading or rendered frame
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
