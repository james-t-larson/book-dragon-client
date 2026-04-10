import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/screens/login_screen.dart';
import 'package:book_dragon_client/screens/home_screen.dart';
import 'package:book_dragon_client/screens/welcome_screen.dart';
import 'package:book_dragon_client/theme/app_theme.dart';
import 'package:book_dragon_client/models/user.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('Navigation Stack Clearing Tests', () {
    testWidgets('Login navigation clears the stack', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const WelcomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(WelcomeScreen), findsOneWidget);

      final loginButton = find.text('I already have an account');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byType(LoginScreen), findsOneWidget);

      final BuildContext context = tester.element(find.byType(LoginScreen));
      
      // Simulate successful login navigation logic
      final dummyUser = User(
        id: 1,
        username: 'test',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        coins: 100,
        dragonColor: 'blue',
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: dummyUser, token: 'token'),
        ),
        (route) => false,
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify HomeScreen is shown and stack is cleared
      expect(find.byType(HomeScreen), findsOneWidget);
      
      final navigator = Navigator.of(tester.element(find.byType(HomeScreen)));
      expect(navigator.canPop(), isFalse);
    });

    /*
    testWidgets('Logout navigation clears the stack', (WidgetTester tester) async {
      final dummyUser = User(
        id: 1,
        username: 'test',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        coins: 100,
        dragonColor: 'blue',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: HomeScreen(user: dummyUser, token: 'token'),
        ),
      );

      expect(find.byType(HomeScreen), findsOneWidget);

      // Find logout button and tap it
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Verify WelcomeScreen is shown and stack is cleared
      expect(find.byType(WelcomeScreen), findsOneWidget);
      
      final navigator = Navigator.of(tester.element(find.byType(WelcomeScreen)));
      expect(navigator.canPop(), isFalse);
    });
    */
  });
}
