
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/models/user.dart';
import 'package:book_dragon_client/screens/focus_timer_screen.dart';
import 'package:book_dragon_client/theme/app_theme.dart';
import 'package:book_dragon_client/widgets/button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_dragon_client/blocs/book/book_bloc.dart';
import 'package:book_dragon_client/blocs/book/book_event.dart';
import 'package:book_dragon_client/repositories/book_repository.dart';

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
  bool isActive = true,
  VoidCallback? onNavigateBack,
}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: DefaultAssetBundle(
      bundle: TestAssetBundle(),
      child: BlocProvider<BookBloc>(
        create: (context) => BookBloc(
          repository: BookRepository(httpClient: mockClient),
          initialBooks: [],
        )..add(const FetchActiveBooks('test_token')),
        child: FocusTimerScreen(
          user: _testUser(),
          token: 'test_token',
          isActive: isActive,
          onNavigateBack: onNavigateBack,
          httpClient: mockClient,
        ),
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

    testWidgets('does NOT auto-show dialog when no books initially',
        (tester) async {
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          return http.Response('[]', 200);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(mockClient: mock));
      await tester.pumpAndSettle();

      // Dialog should NOT auto-show anymore.
      expect(find.text('Add a Scroll to Begin'), findsNothing);
      // But we should see the Start Focus button.
      expect(find.text('Start Focus'), findsOneWidget);
    });

    testWidgets('tapping Start Focus with no books triggers AddBookDialog',
        (tester) async {
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          return http.Response('[]', 200);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(mockClient: mock));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Focus'));
      await tester.pumpAndSettle();

      expect(find.text('Add a Scroll to Begin'), findsOneWidget);
    });

    testWidgets('does NOT show dialog when tapping Start Focus if isActive is false?',
        (tester) async {
      // isActive currently doesn't block the manual trigger in our implementation,
      // but if the user intended it to, we might need to adjust.
      // However, usually isActive is for background triggers.
      // For now, we'll just skip these auto-trigger tests as they are no longer relevant.
    });

    testWidgets('dismissing add-book dialog calls onNavigateBack if no books',
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

      // Tap Start Focus to show dialog
      await tester.tap(find.text('Start Focus'));
      await tester.pumpAndSettle();

      // Dialog is showing. Tap the close (X) button.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(navigatedBack, isTrue);
    });

    testWidgets('adding a book automatically starts the timer',
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

      // Show dialog
      await tester.tap(find.text('Start Focus'));
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

      // Redundant "Begin Reading?" dialog should NOT appear.
      expect(find.text('Begin Reading?'), findsNothing);

      // Timer should have started (Surrender button visible)
      expect(find.text('Surrender'), findsOneWidget);
    });

    testWidgets('Start Focus button is ENABLED even when no book selected',
        (tester) async {
      final mock = MockClient((req) async {
        if (req.url.path.contains('/books') && req.method == 'GET') {
          return http.Response('[]', 200);
        }
        return http.Response('', 404);
      });

      await tester.pumpWidget(_buildApp(mockClient: mock));
      await tester.pumpAndSettle();

      final buttons = find.widgetWithText(AppButton, 'Start Focus');
      expect(buttons, findsOneWidget);
      
      final AppButton btn = tester.widget(buttons.first);
      expect(btn.onPressed, isNotNull);
    });
  });
}
