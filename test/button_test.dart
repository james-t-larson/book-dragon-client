import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_dragon_client/theme/app_theme.dart';
import 'package:book_dragon_client/widgets/button.dart';

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

  group('AppButton Constraints Test', () {
    testWidgets('AppButton limits maximum width to 400.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton(
            onPressed: () {},
            child: const Text('Constrained Elevated'),
          ),
        ),
      );

      final buttonFinder = find.byType(AppButton);
      expect(buttonFinder, findsOneWidget);

      final BuildContext context = tester.element(find.byType(ElevatedButton));
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      
      // Default test screen is 800x600. The button should max out at 400.
      expect(renderBox.size.width, 400.0);
    });

    testWidgets('AppButton.icon limits maximum width to 400.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.star),
            label: const Text('Constrained Icon'),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byWidgetPredicate((w) => w is ElevatedButton));
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      expect(renderBox.size.width, 400.0);
    });

    testWidgets('AppButton.outlined limits maximum width to 400.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton.outlined(
            onPressed: () {},
            child: const Text('Constrained Outlined'),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(OutlinedButton));
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      expect(renderBox.size.width, 400.0);
    });

    testWidgets('AppButton.text limits maximum width to 400.0 (or smaller)', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppButton.text(
            onPressed: () {},
            child: const Text('Constrained Text'),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(TextButton));
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      // Text button shouldn't be full width anyway, but make sure it doesn't cross 400
      expect(renderBox.size.width <= 400.0, isTrue);
    });
  });
}
