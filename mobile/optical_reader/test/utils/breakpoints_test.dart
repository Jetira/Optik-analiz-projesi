import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/utils/breakpoints.dart';

void main() {
  group('Breakpoints', () {
    testWidgets('isMobile returns true for width < 600', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(599, 800)),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.isMobile(context), true);
                expect(Breakpoints.isTablet(context), false);
                expect(Breakpoints.isDesktop(context), false);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isTablet returns true for width 600-840', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.isMobile(context), false);
                expect(Breakpoints.isTablet(context), true);
                expect(Breakpoints.isDesktop(context), false);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isDesktop returns true for width >= 840', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.isMobile(context), false);
                expect(Breakpoints.isTablet(context), false);
                expect(Breakpoints.isDesktop(context), true);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('gridColumns returns 2 for mobile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.gridColumns(context), 2);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('gridColumns returns 3 for tablet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.gridColumns(context), 3);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('gridColumns returns 4 for desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.gridColumns(context), 4);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });
}
