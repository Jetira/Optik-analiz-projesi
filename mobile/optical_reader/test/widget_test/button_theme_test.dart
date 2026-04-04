import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';

void main() {
  group('Button Theme Tests', () {
    test('Light theme has ElevatedButtonTheme configured', () {
      expect(lightTheme.elevatedButtonTheme, isNotNull);
      expect(lightTheme.elevatedButtonTheme.style, isNotNull);
      
      final style = lightTheme.elevatedButtonTheme.style!;
      final minimumSize = style.minimumSize?.resolve({});
      expect(minimumSize, const Size(48, 48));
      
      final padding = style.padding?.resolve({});
      expect(padding, const EdgeInsets.symmetric(horizontal: 24, vertical: 12));
    });

    test('Light theme has OutlinedButtonTheme configured', () {
      expect(lightTheme.outlinedButtonTheme, isNotNull);
      expect(lightTheme.outlinedButtonTheme.style, isNotNull);
      
      final style = lightTheme.outlinedButtonTheme.style!;
      final minimumSize = style.minimumSize?.resolve({});
      expect(minimumSize, const Size(48, 48));
      
      final padding = style.padding?.resolve({});
      expect(padding, const EdgeInsets.symmetric(horizontal: 24, vertical: 12));
    });

    test('Light theme has TextButtonTheme configured', () {
      expect(lightTheme.textButtonTheme, isNotNull);
      expect(lightTheme.textButtonTheme.style, isNotNull);
      
      final style = lightTheme.textButtonTheme.style!;
      final minimumSize = style.minimumSize?.resolve({});
      expect(minimumSize, const Size(48, 48));
      
      final padding = style.padding?.resolve({});
      expect(padding, const EdgeInsets.symmetric(horizontal: 16, vertical: 12));
    });

    test('Light theme has FloatingActionButtonTheme configured', () {
      expect(lightTheme.floatingActionButtonTheme, isNotNull);
      expect(lightTheme.floatingActionButtonTheme.elevation, 6);
      expect(lightTheme.floatingActionButtonTheme.shape, const StadiumBorder());
    });

    test('Dark theme has ElevatedButtonTheme configured', () {
      expect(darkTheme.elevatedButtonTheme, isNotNull);
      expect(darkTheme.elevatedButtonTheme.style, isNotNull);
      
      final style = darkTheme.elevatedButtonTheme.style!;
      final minimumSize = style.minimumSize?.resolve({});
      expect(minimumSize, const Size(48, 48));
    });

    test('Dark theme has OutlinedButtonTheme configured', () {
      expect(darkTheme.outlinedButtonTheme, isNotNull);
      expect(darkTheme.outlinedButtonTheme.style, isNotNull);
      
      final style = darkTheme.outlinedButtonTheme.style!;
      final minimumSize = style.minimumSize?.resolve({});
      expect(minimumSize, const Size(48, 48));
    });

    test('Dark theme has TextButtonTheme configured', () {
      expect(darkTheme.textButtonTheme, isNotNull);
      expect(darkTheme.textButtonTheme.style, isNotNull);
      
      final style = darkTheme.textButtonTheme.style!;
      final minimumSize = style.minimumSize?.resolve({});
      expect(minimumSize, const Size(48, 48));
    });

    test('Dark theme has FloatingActionButtonTheme configured', () {
      expect(darkTheme.floatingActionButtonTheme, isNotNull);
      expect(darkTheme.floatingActionButtonTheme.elevation, 6);
      expect(darkTheme.floatingActionButtonTheme.shape, const StadiumBorder());
    });

    testWidgets('ElevatedButton renders with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Disabled ElevatedButton has null onPressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Disabled'),
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('OutlinedButton renders with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('TextButton renders with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('FloatingActionButton renders with theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
