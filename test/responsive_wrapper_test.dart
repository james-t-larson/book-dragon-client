import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_dragon_client/widgets/responsive_wrapper.dart';
import 'package:book_dragon_client/widgets/unsupported_screen.dart';

void main() {
  testWidgets('Renders child on standard mobile portrait dimensions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveWrapper(
          child: Scaffold(body: Text('Normal Screen')),
        ),
      ),
    );

    expect(find.text('Normal Screen'), findsOneWidget);
    expect(find.byType(UnsupportedScreen), findsNothing);
  });

  testWidgets('Shows UnsupportedScreen overlay on desktop-width dimensions > 900', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveWrapper(
          child: Scaffold(body: Text('Normal Screen')),
        ),
      ),
    );

    expect(find.text('Normal Screen'), findsNothing);
    expect(find.byType(UnsupportedScreen), findsOneWidget);
    expect(find.text("We don't support the web yet, but will in the future."), findsOneWidget);
    expect(find.text('Open App Store'), findsOneWidget);
  });

  testWidgets('Shows UnsupportedScreen overlay on landscape dimensions (small screen)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveWrapper(
          child: Scaffold(body: Text('Normal Screen')),
        ),
      ),
    );

    expect(find.text('Normal Screen'), findsNothing);
    expect(find.byType(UnsupportedScreen), findsOneWidget);
    expect(find.text("We don't support landscape yet, but it's coming."), findsOneWidget);
    expect(find.text('Open App Store'), findsNothing);
  });
}
