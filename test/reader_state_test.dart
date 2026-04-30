import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/screens/welcome_screen.dart';
import 'package:book_dragon_client/screens/dragon_selection_screen.dart';
import 'package:book_dragon_client/screens/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:book_dragon_client/models/user.dart';
import 'package:book_dragon_client/theme/app_theme.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_dragon_client/blocs/book/book_bloc.dart';
import 'package:book_dragon_client/repositories/book_repository.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.startsWith('assets/images/')) {
      return ByteData.view(Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
      ]).buffer);
    }
    return rootBundle.load(key);
  }
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Reader Potential States Tests', () {
    testWidgets('State 1: Unauthenticated (Welcome Screen)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const WelcomeScreen(),
        ),
      );

      // Verify the state of the unauthenticated user
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Book Dragon'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // Should have background/dragon image
    });

    testWidgets('State 2: Authenticated doesn\'t have a dragon (Dragon Selection Screen)', (WidgetTester tester) async {
      final userNoDragon = User(
        id: 1,
        username: 'readerTest',
        email: 'reader@example.com',
        createdAt: DateTime.now(),
        coins: 0,
        // No dragonId or dragonColor yet
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: DragonSelectionScreen(
              user: userNoDragon,
              token: 'mock_token_123',
            ),
          ),
        ),
      );

      // Verify the state for an authenticated reader without a dragon
      expect(find.byType(DragonSelectionScreen), findsOneWidget);
    });

    testWidgets('State 3: Authenticated has dragon (Home Screen)', (WidgetTester tester) async {
      final userWithDragon = User(
        id: 2,
        username: 'veteranReader',
        email: 'veteran@example.com',
        createdAt: DateTime.now(),
        coins: 50,
        dragonColor: 'blue',
        dragonId: 10,
      );

      final mockBookClient = MockClient((_) async => http.Response('[]', 200));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: BlocProvider<BookBloc>(
              create: (_) => BookBloc(
                repository: BookRepository(httpClient: mockBookClient),
                initialBooks: [],
              ),
              child: HomeScreen(
                user: userWithDragon,
                token: 'mock_token_456',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Wait for circular progress to disappear
      // Verify the state for an authenticated reader who already has a dragon
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Library'), findsOneWidget); // AppBar title
      
      // The Home Screen uses BottomNavigationBar or similar navigation
      // Let's ensure the profile or coins section displays
      expect(find.text('Coins: 50'), findsOneWidget); 
    });
  });
}
