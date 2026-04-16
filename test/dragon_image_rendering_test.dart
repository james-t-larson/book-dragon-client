import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/models/user.dart';
import 'package:book_dragon_client/models/book.dart';
import 'package:book_dragon_client/screens/welcome_screen.dart';
import 'package:book_dragon_client/screens/splash_screen.dart';
import 'package:book_dragon_client/screens/dragon_selection_screen.dart';
import 'package:book_dragon_client/screens/focus_timer_screen.dart';
import 'package:book_dragon_client/widgets/dragon_art.dart';

void main() {
  final List<String> allColors = ['red', 'blue', 'moss', 'gold', 'pink', 'white'];

  User createDummyUser(String color) {
    return User(
      id: 1,
      username: 'testreader',
      email: 'test@example.com',
      createdAt: DateTime.now(),
      coins: 100,
      dragonColor: color,
      dragonId: 1,
    );
  }

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dragon Image Rendering Tests', () {
    // Tests that these widgets mount successfully and Image.asset locates the files
    // on the filesystem properly without throwing "Unable to load asset" errors.

    testWidgets('WelcomeScreen renders random dragon asset successfully', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 100)); // Allow time for asset lookup validation
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('SplashScreen renders its gold dragon successfully', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Image), findsWidgets);

      // Cleanup to avoid pending timer from its Future.delayed
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('DragonSelectionScreen renders all dragon options successfully', (tester) async {
      final user = createDummyUser('red'); 
      await tester.pumpWidget(
        MaterialApp(
          home: DragonSelectionScreen(user: user, token: 'fake_token'),
        )
      );
      await tester.pumpAndSettle(); 
      expect(find.byType(Image), findsWidgets);
    });

    for (final color in allColors) {
      testWidgets('DragonArt widget renders successfully for color: $color', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DragonArt(colorName: color),
            ),
          )
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('FocusTimerScreen renders its dragon successfully for color: $color', (tester) async {
        final user = createDummyUser(color);
        final book = Book(id: 1, title: 'Test Book', totalPages: 100, currentPage: 0);

        await tester.pumpWidget(
          MaterialApp(
            home: FocusTimerScreen(
              user: user,
              token: 'fake_token',
            )
          )
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(Image), findsWidgets);
      });
    }
  });
}
