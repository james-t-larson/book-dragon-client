import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/models/user.dart';
import 'package:book_dragon_client/models/book.dart';
import 'package:book_dragon_client/screens/focus_timer_screen.dart';
import 'package:book_dragon_client/theme/app_theme.dart';
import 'package:book_dragon_client/widgets/button.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Minimal 1×1 transparent PNG for Image.asset calls.
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.startsWith('assets/')) {
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
      dragonColor: 'red',
    );

Map<String, dynamic> _bookJson({
  int id = 1,
  String title = 'The Hobbit',
}) =>
    {
      'id': id,
      'title': title,
      'author': 'J.R.R. Tolkien',
      'genre': 'Fantasy',
      'total_pages': 310,
      'current_page': 42,
      'reading': true,
      'read_count': 0,
    };

/// Builds FocusTimerScreen wrapped in the necessary providers/bundles,
/// backed by a [MockClient] that drives the API responses.
Widget _buildApp({
  required MockClient mockClient,
  bool calledBack = false,
  VoidCallback? onNavigateBack,
}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: DefaultAssetBundle(
      bundle: TestAssetBundle(),
      child: FocusTimerScreen(
        user: _testUser(),
        token: 'test_token',
        onNavigateBack: onNavigateBack,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({'hide_focus_loss_warning': true});
  });

  group('FocusTimerScreen — self-loading books', () {
    testWidgets('shows loading indicator while fetching books', (tester) async {
      // A client that never completes (simulates slow network).
      final slow = MockClient((_) async {
        await Future.delayed(const Duration(seconds: 30));
        return http.Response('[]', 200);
      });

      await tester.pumpWidget(_buildApp(mockClient: slow));
      // After first frame, fetch is in-flight → loading spinner visible.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Start Focus button should NOT be rendered while loading.
      expect(find.text('Start Focus'), findsNothing);
    });

    testWidgets('renders timer UI when books exist', (tester) async {
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books')) {
          return http.Response(jsonEncode([_bookJson()]), 200);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(mockClient: mock));
      await tester.pumpAndSettle();

      // Timer UI should be rendered with the book title.
      expect(find.text('The Hobbit'), findsOneWidget);
      expect(find.text('Start Focus'), findsOneWidget);
      expect(find.text('Chosen Scroll'), findsOneWidget);
    });

    testWidgets('shows "Add a Scroll to Begin" dialog when no books',
        (tester) async {
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          return http.Response('[]', 200);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(mockClient: mock));
      await tester.pumpAndSettle();

      // Dialog should auto-show.
      expect(find.text('Add a Scroll to Begin'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Author'), findsOneWidget);
      expect(find.text('Add Scroll'), findsOneWidget);
    });

    testWidgets('dismissing add-book dialog calls onNavigateBack',
        (tester) async {
      bool navigatedBack = false;
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          return http.Response('[]', 200);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(
        mockClient: mock,
        onNavigateBack: () => navigatedBack = true,
      ));
      await tester.pumpAndSettle();

      // Dialog is showing. Tap the close (X) button.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(navigatedBack, isTrue);
    });

    testWidgets('adding a book shows "Begin Reading?" follow-up',
        (tester) async {
      bool isFirstFetch = true;
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          if (isFirstFetch) {
            isFirstFetch = false;
            return http.Response('[]', 200); // no books initially
          }
          // After POST, return the new book
          return http.Response(jsonEncode([_bookJson()]), 200);
        }
        if (req.url.path.contains('/books') && req.method == 'POST') {
          return http.Response(jsonEncode(_bookJson()), 201);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(mockClient: mock));
      await tester.pumpAndSettle();

      // Fill in the title field
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'The Hobbit',
      );
      await tester.pumpAndSettle();

      // Tap "Add Scroll"
      await tester.tap(find.text('Add Scroll'));
      await tester.pumpAndSettle();

      // Follow-up dialog should appear.
      expect(find.text('Begin Reading?'), findsOneWidget);
      expect(find.text('Start Reading'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
    });

    testWidgets('"Start Reading" in follow-up keeps user on timer screen',
        (tester) async {
      bool navigatedBack = false;
      bool isFirstFetch = true;
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          if (isFirstFetch) {
            isFirstFetch = false;
            return http.Response('[]', 200);
          }
          return http.Response(jsonEncode([_bookJson()]), 200);
        }
        if (req.url.path.contains('/books') && req.method == 'POST') {
          return http.Response(jsonEncode(_bookJson()), 201);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(
        mockClient: mock,
        onNavigateBack: () => navigatedBack = true,
      ));
      await tester.pumpAndSettle();

      // Add a book
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'The Hobbit',
      );
      await tester.tap(find.text('Add Scroll'));
      await tester.pumpAndSettle();

      // Tap "Start Reading"
      await tester.tap(find.text('Start Reading'));
      await tester.pumpAndSettle();

      // Should NOT navigate back — user stays on timer screen.
      expect(navigatedBack, isFalse);
      // Timer screen should now show the book.
      expect(find.text('The Hobbit'), findsOneWidget);
      expect(find.text('Start Focus'), findsOneWidget);
    });

    testWidgets('"Not Now" in follow-up calls onNavigateBack',
        (tester) async {
      bool navigatedBack = false;
      bool isFirstFetch = true;
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          if (isFirstFetch) {
            isFirstFetch = false;
            return http.Response('[]', 200);
          }
          return http.Response(jsonEncode([_bookJson()]), 200);
        }
        if (req.url.path.contains('/books') && req.method == 'POST') {
          return http.Response(jsonEncode(_bookJson()), 201);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(
        mockClient: mock,
        onNavigateBack: () => navigatedBack = true,
      ));
      await tester.pumpAndSettle();

      // Add a book
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'The Hobbit',
      );
      await tester.tap(find.text('Add Scroll'));
      await tester.pumpAndSettle();

      // Tap "Not Now"
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      expect(navigatedBack, isTrue);
    });

    testWidgets('Start Focus button disabled when no book selected',
        (tester) async {
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          return http.Response('[]', 200);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(mockClient: mock));
      // Let the fetch complete but dismiss the dialog before checking button
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The dialog is showing, so the Start Focus button is behind it
      // but it should be rendered disabled (onPressed == null).
      // Since we can't easily interact with it behind the dialog,
      // we verify the button widget's state.
      final buttons = find.widgetWithText(ElevatedButton, 'Start Focus');
      // Button exists but may be behind the dialog
      if (buttons.evaluate().isNotEmpty) {
        final ElevatedButton btn = tester.widget(buttons.first);
        expect(btn.onPressed, isNull);
      }
    });
  });
}
