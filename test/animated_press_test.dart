import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_2415051045_rendiwijakusuma/widgets/animated_press.dart';

void main() {
  testWidgets('AnimatedPress scales down while the button is pressed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedPress(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Tekan'),
              ),
            ),
          ),
        ),
      ),
    );

    final scaleFinder = find.descendant(
      of: find.byType(AnimatedPress),
      matching: find.byType(AnimatedScale),
    );
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Tekan')),
    );
    await tester.pump(const Duration(milliseconds: 110));
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 0.96);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1);
  });
}
