import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';

void main() {
  group('Theme Widget Integration Tests', () {
    testWidgets('Card should render with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Card(
              child: Container(
                width: 100,
                height: 100,
                child: const Text('Test Card'),
              ),
            ),
          ),
        ),
      );

      // Verify the Card is rendered
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Card'), findsOneWidget);
    });

    testWidgets('TextField should apply theme styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: TextField(
              decoration: const InputDecoration(
                labelText: 'Test Input',
                helperText: 'Helper text',
              ),
            ),
          ),
        ),
      );

      // Verify the TextField is rendered
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Input'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);
    });

    testWidgets('TextField should show error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: TextField(
              decoration: const InputDecoration(
                labelText: 'Test Input',
                errorText: 'Error message',
              ),
            ),
          ),
        ),
      );

      // Verify error text is displayed
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('TextField should have floating label behavior', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Test Label',
              ),
            ),
          ),
        ),
      );

      // Initially, label should be visible
      expect(find.text('Test Label'), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Test text');
      await tester.pump();

      // Label should still be visible (floating)
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test text'), findsOneWidget);
    });

    testWidgets('ElevatedButton should render with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Verify the button is rendered
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('OutlinedButton should render with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: OutlinedButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Verify the button is rendered
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('Dark theme should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: Card(
              child: Container(
                width: 100,
                height: 100,
                child: const Text('Test Card'),
              ),
            ),
          ),
        ),
      );

      // Verify the Card is rendered with dark theme
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Card'), findsOneWidget);
    });
  });
}
