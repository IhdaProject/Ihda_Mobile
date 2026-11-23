import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ihda_mobile/shared/widgets/responsive_action_row.dart';

void main() {
  for (final width in [240.0, 320.0, 430.0]) {
    testWidgets('actions fit at width $width with large text', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                      width: width,
                      child: MediaQuery(
                          data: const MediaQueryData(
                              textScaler: TextScaler.linear(1.6)),
                          child: ResponsiveActionRow(children: [
                            const Text('12 ta o‘quv kursi mavjud'),
                            ElevatedButton(
                                onPressed: () {}, child: const Text('Batafsil'))
                          ])))))));
      expect(tester.takeException(), isNull);
    });
  }
}
