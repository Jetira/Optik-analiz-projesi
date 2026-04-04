import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';

/// Integration test to verify button themes work correctly in a real app context
/// This test verifies all Requirements 8.1-8.6 in an integrated scenario
void main() {
  group('Button Theme Integration Tests', () {
    testWidgets('All button types render correctly in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Button Test')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Requirement 8.1: Primary action button
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  const SizedBox(height: 16),
                  // Requirement 8.2: Secondary action button
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Secondary'),
                  ),
                  const SizedBox(height: 16),
                  // Requirement 8.3: Tertiary action button
                  TextButton(
                    onPressed: () {},
                    child: const Text('Tertiary'),
                  ),
                  const SizedBox(height: 16),
                  // Requirement 8.5: Disabled states
                  ElevatedButton(
                    onPressed: null,
                    child: const Text('Disabled'),
                  ),
                ],
              ),
            ),
            // Requirement 8.4: Floating action button
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('FAB'),
            ),
          ),
        ),
      );

      // Verify all buttons are rendered
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Tertiary'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('FAB'), findsOneWidget);

      // Verify button types
      expect(find.byType(ElevatedButton), findsNWidgets(2)); // Primary + Disabled
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('All button types render correctly in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            appBar: AppBar(title: const Text('Button Test')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Secondary'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Tertiary'),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Verify all buttons are rendered in dark theme
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Tertiary'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Button interactions work correctly',
        (WidgetTester tester) async {
      int primaryPressed = 0;
      int secondaryPressed = 0;
      int tertiaryPressed = 0;
      int fabPressed = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => primaryPressed++,
                    child: const Text('Primary'),
                  ),
                  OutlinedButton(
                    onPressed: () => secondaryPressed++,
                    child: const Text('Secondary'),
                  ),
                  TextButton(
                    onPressed: () => tertiaryPressed++,
                    child: const Text('Tertiary'),
                  ),
                  ElevatedButton(
                    onPressed: null,
                    child: const Text('Disabled'),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => fabPressed++,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Test enabled button interactions
      await tester.tap(find.text('Primary'));
      await tester.pump();
      expect(primaryPressed, 1);

      await tester.tap(find.text('Secondary'));
      await tester.pump();
      expect(secondaryPressed, 1);

      await tester.tap(find.text('Tertiary'));
      await tester.pump();
      expect(tertiaryPressed, 1);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(fabPressed, 1);

      // Test disabled button doesn't respond
      final disabledButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Disabled'),
      );
      expect(disabledButton.onPressed, isNull);
    });

    testWidgets('Button hierarchy is visually distinct',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Most Important'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Important'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Less Important'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify all three button types are present and distinct
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      // Verify they all have the correct minimum size (Requirement 8.6)
      final elevatedStyle = lightTheme.elevatedButtonTheme.style!;
      final outlinedStyle = lightTheme.outlinedButtonTheme.style!;
      final textStyle = lightTheme.textButtonTheme.style!;

      expect(
        elevatedStyle.minimumSize?.resolve({}),
        const Size(48, 48),
      );
      expect(
        outlinedStyle.minimumSize?.resolve({}),
        const Size(48, 48),
      );
      expect(
        textStyle.minimumSize?.resolve({}),
        const Size(48, 48),
      );
    });

    testWidgets('Buttons with icons render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info),
                    label: const Text('Info'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify buttons with icons render
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });
  });
}
