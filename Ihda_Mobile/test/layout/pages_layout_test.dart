import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihda_mobile/features/important_dates/presentation/screens/important_dates_screen.dart';
import 'package:ihda_mobile/features/quran_courses/presentation/screens/quran_courses_screen.dart';

void main() {
  for (final screen in <Widget>[
    const ImportantDatesScreen(),
    const QuranCoursesScreen()
  ]) {
    testWidgets('${screen.runtimeType} fits narrow screen', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.3)),
                  child: child!),
              home: screen)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
