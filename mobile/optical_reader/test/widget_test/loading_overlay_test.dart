import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/widgets/loading_overlay.dart';
import 'package:optical_reader/app/theme.dart';

void main() {
  group('LoadingOverlay Widget Tests', () {
    testWidgets('displays CircularProgressIndicator and message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Verify CircularProgressIndicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify message is displayed
      expect(find.text('Yükleniyor...'), findsOneWidget);
    });

    testWidgets('uses default message when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(),
          ),
        ),
      );

      // Verify default message is displayed
      expect(find.text('Yükleniyor...'), findsOneWidget);
    });

    testWidgets('displays custom message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Veriler işleniyor...'),
          ),
        ),
      );

      // Verify custom message is displayed
      expect(find.text('Veriler işleniyor...'), findsOneWidget);
    });

    testWidgets('has semi-transparent background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Find the Container widget
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ),
      );

      // Verify background color has opacity
      final decoration = container.color;
      expect(decoration, isNotNull);
      expect(decoration, equals(Colors.black.withOpacity(0.5)));
    });

    testWidgets('content is wrapped in a Card', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Verify Card exists
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('content is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Verify Center widget exists
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Find all Padding widgets inside the Card
      final paddingWidgets = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );

      // There should be at least one Padding widget
      expect(paddingWidgets, findsWidgets);
      
      // Find the specific Padding widget that wraps the Column
      final padding = tester.widgetList<Padding>(paddingWidgets).firstWhere(
        (widget) => widget.padding == const EdgeInsets.all(AppSpacing.lg),
      );

      // Verify padding is 24dp (AppSpacing.lg)
      expect(padding.padding, equals(const EdgeInsets.all(AppSpacing.lg)));
    });

    testWidgets('has correct spacing between indicator and message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Find the Column widget
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Column),
        ),
      );

      // Verify Column has correct children
      expect(column.children.length, 3);
      expect(column.children[0], isA<CircularProgressIndicator>());
      expect(column.children[1], isA<SizedBox>());
      expect(column.children[2], isA<Text>());

      // Verify SizedBox has correct height (16dp = AppSpacing.md)
      final sizedBox = column.children[1] as SizedBox;
      expect(sizedBox.height, equals(AppSpacing.md));
    });

    testWidgets('Column has mainAxisSize.min', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Find the Column widget
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Column),
        ),
      );

      // Verify mainAxisSize is min
      expect(column.mainAxisSize, equals(MainAxisSize.min));
    });

    testWidgets('works in a Stack overlay pattern',
        (WidgetTester tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Center(child: Text('Main Content')),
                if (isLoading)
                  const LoadingOverlay(message: 'Loading...'),
              ],
            ),
          ),
        ),
      );

      // Verify both main content and overlay are present
      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('overlay covers entire screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      // Get the Container size
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ),
      );

      // Container should not have explicit size constraints
      // (it should fill available space)
      expect(container.constraints, isNull);
    });

    testWidgets('works with light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      expect(find.byType(LoadingOverlay), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('works with dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const Scaffold(
            body: LoadingOverlay(message: 'Yükleniyor...'),
          ),
        ),
      );

      expect(find.byType(LoadingOverlay), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
