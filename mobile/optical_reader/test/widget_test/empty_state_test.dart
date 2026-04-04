import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('displays icon, title, subtitle, and action button',
        (WidgetTester tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.school_outlined,
              title: 'No Items',
              subtitle: 'Get started by creating a new item',
              actionLabel: 'Create Item',
              onActionPressed: () {
                actionPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify icon is displayed
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);

      // Verify title is displayed
      expect(find.text('No Items'), findsOneWidget);

      // Verify subtitle is displayed
      expect(find.text('Get started by creating a new item'), findsOneWidget);

      // Verify action button is displayed
      expect(find.widgetWithText(OutlinedButton, 'Create Item'), findsOneWidget);

      // Verify action button callback works
      await tester.tap(find.widgetWithText(OutlinedButton, 'Create Item'));
      await tester.pump();
      expect(actionPressed, true);
    });

    testWidgets('icon has correct size and color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.school_outlined,
              title: 'No Items',
              subtitle: 'Get started',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.school_outlined));
      expect(iconWidget.size, 48);
      expect(iconWidget.color, isNotNull);
    });

    testWidgets('uses theme colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: EmptyState(
              icon: Icons.school_outlined,
              title: 'No Items',
              subtitle: 'Get started',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.school_outlined));
      final context = tester.element(find.byType(EmptyState));
      expect(iconWidget.color, Theme.of(context).colorScheme.outline);
    });

    testWidgets('has proper spacing between elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.school_outlined,
              title: 'No Items',
              subtitle: 'Get started',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Verify SizedBox spacing exists
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('text is center aligned', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.school_outlined,
              title: 'No Items',
              subtitle: 'Get started',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('No Items'));
      expect(titleText.textAlign, TextAlign.center);

      final subtitleText = tester.widget<Text>(find.text('Get started'));
      expect(subtitleText.textAlign, TextAlign.center);
    });

    testWidgets('is wrapped in a Card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.school_outlined,
              title: 'No Items',
              subtitle: 'Get started',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('action button has add icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.school_outlined,
              title: 'No Items',
              subtitle: 'Get started',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Find the OutlinedButton and verify it has an add icon
      final button = find.widgetWithText(OutlinedButton, 'Create');
      expect(button, findsOneWidget);
      
      // Verify add icon exists within the button
      expect(find.descendant(
        of: button,
        matching: find.byIcon(Icons.add),
      ), findsOneWidget);
    });
  });
}
