import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';
import 'package:optical_reader/utils/snackbar_helpers.dart';

void main() {
  group('SnackBar Helper Tests', () {
    testWidgets('showSuccessSnackBar displays success snackbar with correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showSuccessSnackBar(context, 'Success message');
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show snackbar
      await tester.tap(find.text('Show Success'));
      await tester.pump();

      // Verify snackbar is displayed
      expect(find.text('Success message'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Verify the snackbar has correct background color
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, AppColors.success);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(seconds: 3));
    });

    testWidgets('showErrorSnackBar displays error snackbar with correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showErrorSnackBar(context, 'Error message');
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show snackbar
      await tester.tap(find.text('Show Error'));
      await tester.pump();

      // Verify snackbar is displayed
      expect(find.text('Error message'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);

      // Verify the snackbar has correct background color
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, AppColors.error);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(seconds: 3));
    });

    testWidgets('showInfoSnackBar displays info snackbar with correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showInfoSnackBar(context, 'Info message');
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show snackbar
      await tester.tap(find.text('Show Info'));
      await tester.pump();

      // Verify snackbar is displayed
      expect(find.text('Info message'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);

      // Verify the snackbar has correct background color
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, AppColors.info);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(seconds: 3));
    });

    testWidgets('showSuccessSnackBar supports optional action parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showSuccessSnackBar(
                      context,
                      'Success with action',
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {},
                      ),
                    );
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show snackbar
      await tester.tap(find.text('Show Success'));
      await tester.pump();

      // Verify action button is displayed
      expect(find.text('UNDO'), findsOneWidget);
      
      // Verify the snackbar has an action
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.action, isNotNull);
      expect(snackBar.action!.label, 'UNDO');
    });

    testWidgets('snackbar has 3 second duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showSuccessSnackBar(context, 'Duration test');
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show snackbar
      await tester.tap(find.text('Show Success'));
      await tester.pump();

      // Verify snackbar is displayed with correct duration
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(seconds: 3));
    });

    testWidgets('snackbar has rounded corners with 8dp radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showSuccessSnackBar(context, 'Shape test');
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show snackbar
      await tester.tap(find.text('Show Success'));
      await tester.pump();

      // Verify the snackbar has correct shape
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final shape = snackBar.shape as RoundedRectangleBorder;
      final borderRadius = shape.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, 8.0);
      expect(borderRadius.topRight.x, 8.0);
      expect(borderRadius.bottomLeft.x, 8.0);
      expect(borderRadius.bottomRight.x, 8.0);
    });
  });
}
