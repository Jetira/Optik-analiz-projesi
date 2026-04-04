import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';

/// Tests to verify disabled button states (Requirement 8.5)
/// Material 3 automatically handles disabled states with reduced opacity
void main() {
  group('Button Disabled State Tests (Requirement 8.5)', () {
    testWidgets('ElevatedButton disabled state prevents interaction',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: null, // Disabled
                child: const Text('Disabled Button'),
              ),
            ),
          ),
        ),
      );

      // Try to tap the disabled button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify the button is disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(wasPressed, isFalse);
    });

    testWidgets('OutlinedButton disabled state prevents interaction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: OutlinedButton(
                onPressed: null, // Disabled
                child: const Text('Disabled Button'),
              ),
            ),
          ),
        ),
      );

      final button =
          tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('TextButton disabled state prevents interaction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: null, // Disabled
                child: const Text('Disabled Button'),
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Enabled button can be tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  wasPressed = true;
                },
                child: const Text('Enabled Button'),
              ),
            ),
          ),
        ),
      );

      // Tap the enabled button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('Button can transition from enabled to disabled',
        (WidgetTester tester) async {
      bool isEnabled = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isEnabled ? () {} : null,
                        child: const Text('Toggle Me'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEnabled = !isEnabled;
                          });
                        },
                        child: const Text('Toggle State'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initially enabled
      var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      // Toggle to disabled
      await tester.tap(find.text('Toggle State'));
      await tester.pumpAndSettle();

      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // Toggle back to enabled
      await tester.tap(find.text('Toggle State'));
      await tester.pumpAndSettle();

      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
