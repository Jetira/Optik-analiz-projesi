import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/widgets/stat_card.dart';
import 'package:optical_reader/app/theme.dart';

void main() {
  group('StatCard Widget Tests', () {
    testWidgets('displays icon, label, and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      // Verify icon is displayed
      expect(find.byIcon(Icons.school), findsOneWidget);

      // Verify label is displayed
      expect(find.text('Total Students'), findsOneWidget);

      // Verify value is displayed
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('icon has correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.school));
      expect(iconWidget.size, 24);
    });

    testWidgets('uses primary color for icon by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.school));
      final context = tester.element(find.byType(StatCard));
      expect(iconWidget.color, Theme.of(context).colorScheme.primary);
    });

    testWidgets('uses custom icon color when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
              iconColor: Colors.red,
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.school));
      expect(iconWidget.color, Colors.red);
    });

    testWidgets('displays positive trend indicator correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
              trendPercentage: 15.5,
            ),
          ),
        ),
      );

      // Verify upward arrow is displayed
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      // Verify percentage is displayed
      expect(find.text('15.5%'), findsOneWidget);

      // Verify trend indicator uses success color
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      expect(iconWidget.color, AppColors.success);
    });

    testWidgets('displays negative trend indicator correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
              trendPercentage: -8.3,
            ),
          ),
        ),
      );

      // Verify downward arrow is displayed
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

      // Verify percentage is displayed (absolute value)
      expect(find.text('8.3%'), findsOneWidget);

      // Verify trend indicator uses error color
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
      expect(iconWidget.color, AppColors.error);
    });

    testWidgets('displays zero trend as positive', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
              trendPercentage: 0.0,
            ),
          ),
        ),
      );

      // Verify upward arrow is displayed for zero
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      // Verify percentage is displayed
      expect(find.text('0.0%'), findsOneWidget);
    });

    testWidgets('does not display trend indicator when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      // Verify no trend arrows are displayed
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('is wrapped in a Card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      // Find the main Padding widget that wraps the Column
      final paddingWidgets = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        ),
      );

      // The first Padding should be the main one with AppSpacing.md
      final mainPadding = paddingWidgets.firstWhere(
        (p) => p.padding == const EdgeInsets.all(AppSpacing.md),
        orElse: () => throw Exception('Main padding not found'),
      );

      expect(mainPadding.padding, const EdgeInsets.all(AppSpacing.md));
    });

    testWidgets('label uses titleSmall text style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Total Students'));
      final context = tester.element(find.byType(StatCard));
      expect(labelText.style, Theme.of(context).textTheme.titleSmall);
    });

    testWidgets('value uses displaySmall text style with bold weight',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
            ),
          ),
        ),
      );

      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('label truncates with ellipsis when too long',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: StatCard(
                icon: Icons.school,
                label: 'Very Long Label That Should Truncate',
                value: '42',
              ),
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(
        find.text('Very Long Label That Should Truncate'),
      );
      expect(labelText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('has proper spacing between elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
              trendPercentage: 10.0,
            ),
          ),
        ),
      );

      // Verify SizedBox spacing exists
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('works in grid layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.count(
              crossAxisCount: 2,
              children: [
                StatCard(
                  icon: Icons.school,
                  label: 'Students',
                  value: '42',
                ),
                StatCard(
                  icon: Icons.quiz,
                  label: 'Questions',
                  value: '100',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify both cards are displayed
      expect(find.byType(StatCard), findsNWidgets(2));
      expect(find.text('Students'), findsOneWidget);
      expect(find.text('Questions'), findsOneWidget);
    });
  });
}
