import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_dragon_client/theme/app_theme.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    );
  }

  group('Button Baseline Tests', () {
    testWidgets('ElevatedButton renders, defaults to full width, and handles presses', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          ElevatedButton(
            onPressed: () => pressed = true,
            child: const Text('Elevated Base'),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Elevated Base'), findsOneWidget);

      final BuildContext context = tester.element(buttonFinder);
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      
      // Default test screen is 800x600. Theme is set to double.infinity minimum width.
      expect(renderBox.size.width, 800.0);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('ElevatedButton.icon renders, defaults to full width, and handles presses', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          ElevatedButton.icon(
            onPressed: () => pressed = true,
            icon: const Icon(Icons.star),
            label: const Text('Elevated Icon Base'),
          ),
        ),
      );

      final buttonFinder = find.byWidgetPredicate((widget) => widget is ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Elevated Icon Base'), findsOneWidget);

      final BuildContext context = tester.element(buttonFinder);
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      expect(renderBox.size.width, 800.0);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('OutlinedButton renders, defaults to full width, and handles presses', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          OutlinedButton(
            onPressed: () => pressed = true,
            child: const Text('Outlined Base'),
          ),
        ),
      );

      final buttonFinder = find.byType(OutlinedButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Outlined Base'), findsOneWidget);

      final BuildContext context = tester.element(buttonFinder);
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      expect(renderBox.size.width, 800.0);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('TextButton renders, does NOT default to full width (no theme override), and handles presses', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        buildTestWidget(
          TextButton(
            onPressed: () => pressed = true,
            child: const Text('Text Base'),
          ),
        ),
      );

      final buttonFinder = find.byType(TextButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Text Base'), findsOneWidget);

      // TextButton is not modified in AppTheme with minimum width
      final BuildContext context = tester.element(buttonFinder);
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      expect(renderBox.size.width < 800.0, isTrue); // Should only take intrinsic width

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });
  });
}
