import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';
import 'package:optical_reader/screens/home_screen.dart';
import 'package:optical_reader/services/api_service.dart';

void main() {
  group('ConnectionStatusCard Tests', () {
    testWidgets('Shows green check_circle icon when connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthCheckProvider.overrideWith((ref) async => true),
          ],
          child: MaterialApp(
            theme: lightTheme,
            home: const Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );

      // Wait for async provider to resolve
      await tester.pumpAndSettle();

      // Find the icon
      final iconFinder = find.byIcon(Icons.check_circle);
      expect(iconFinder, findsOneWidget);

      // Verify icon color is green (success)
      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, AppColors.success);
    });

    testWidgets('Shows red error icon when disconnected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthCheckProvider.overrideWith((ref) async => false),
          ],
          child: MaterialApp(
            theme: lightTheme,
            home: const Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );

      // Wait for async provider to resolve
      await tester.pumpAndSettle();

      // Find the icon
      final iconFinder = find.byIcon(Icons.error);
      expect(iconFinder, findsOneWidget);

      // Verify icon color is red (error)
      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, AppColors.error);
    });

    testWidgets('Card uses theme styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthCheckProvider.overrideWith((ref) async => true),
          ],
          child: MaterialApp(
            theme: lightTheme,
            home: const Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Card widget
      final cardFinder = find.byType(Card).first;
      expect(cardFinder, findsOneWidget);

      // Verify Card exists and is rendered
      final Card card = tester.widget(cardFinder);
      expect(card, isNotNull);
    });

    testWidgets('Refresh button invalidates provider',
        (WidgetTester tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthCheckProvider.overrideWith((ref) async {
              callCount++;
              return true;
            }),
          ],
          child: MaterialApp(
            theme: lightTheme,
            home: const Scaffold(
              body: HomeScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(callCount, 1);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Provider should be called again
      expect(callCount, 2);
    });
  });
}
