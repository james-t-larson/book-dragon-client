import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/models/user.dart';
import 'package:book_dragon_client/screens/main_navigation_screen.dart';

import 'package:book_dragon_client/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Minimal 1×1 transparent PNG so Image.asset calls don't fail in tests.
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.startsWith('assets/images/')) {
      return ByteData.view(Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
        0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
        0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5,
        0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66,
        96, 130,
      ]).buffer);
    }
    return rootBundle.load(key);
  }
}

User _testUser() => User(
      id: 1,
      username: 'testReader',
      email: 'reader@book.dragon',
      createdAt: DateTime(2026, 1, 1),
      coins: 42,
      dragonId: 10,
      dragonName: 'Mossy',
      dragonColor: 'moss',
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MainNavigationScreen — IndexedStack navigation', () {
    testWidgets('renders BottomNavigationBar with 3 items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
            ),
          ),
        ),
      );
      await tester.pump();

      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // Verify 3 navigation items
      expect(find.text('Focus'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Tourney'), findsOneWidget);
    });

    testWidgets('defaults to Home tab (index 1)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
            ),
          ),
        ),
      );
      await tester.pump();

      // The IndexedStack's current index should be 1 (Home)
      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.index, 1);
    });

    testWidgets('supports custom initial index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
              initialIndex: 2,
            ),
          ),
        ),
      );
      await tester.pump();

      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.index, 2);
    });

    testWidgets('tapping Focus tab switches to index 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap the Focus tab
      await tester.tap(find.text('Focus'));
      await tester.pump();

      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.index, 0);
    });

    testWidgets('tapping Tourney tab switches to index 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap the Tourney tab
      await tester.tap(find.text('Tourney'));
      await tester.pump();

      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.index, 2);
    });

    testWidgets('uses IndexedStack to keep all three screens alive',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify IndexedStack is present
      expect(find.byType(IndexedStack), findsOneWidget);

      // Verify all three screens exist in the stack (not just the active one)
      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.children.length, 3);
    });

    testWidgets('icons match spec — clock, home, swords', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
            ),
          ),
        ),
      );
      await tester.pump();

      // Clock icon for Focus
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      // Home icon (active by default)
      expect(find.byIcon(Icons.home), findsOneWidget);
      // Crossed swords / kabaddi icon for Tourney
      expect(find.byIcon(Icons.sports_kabaddi), findsWidgets);
    });

    testWidgets('switching tabs preserves IndexedStack structure',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: MainNavigationScreen(
              user: _testUser(),
              token: 'test_token',
            ),
          ),
        ),
      );
      await tester.pump();

      // Start at Home (1), go to Tourney (2), then back to Home (1)
      await tester.tap(find.text('Tourney'));
      await tester.pump();

      var stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 2);
      expect(stack.children.length, 3); // all still present

      await tester.tap(find.text('Home'));
      await tester.pump();

      stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 1);
      expect(stack.children.length, 3); // still all present
    });
  });
}
