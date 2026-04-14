import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/screens/splash_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('SplashScreen UI Tests', () {
    testWidgets('Renders themed elements correctly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Check for Dragon Image (gold.png)
      expect(find.byType(Image), findsOneWidget);
      
      // Check for "Book Dragon" title
      expect(find.text('Book Dragon'), findsOneWidget);
      
      // Check for "Waking the dragon..." message
      expect(find.text('Waking the dragon...'), findsOneWidget);

      // Cleanup to avoid pending timer from _checkAuthStatus delay
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Displays animations and background gradient', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify presence of animations (ScaleTransition and AnimatedBuilder/Container)
      expect(find.byType(ScaleTransition), findsWidgets);
      
      // Background check - container with gradient
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<RadialGradient>());

      // Cleanup to avoid pending timer from _checkAuthStatus delay
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
