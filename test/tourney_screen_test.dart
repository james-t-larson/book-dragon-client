import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:book_dragon_client/models/user.dart';

import 'package:book_dragon_client/screens/tourney_screen.dart';
import 'package:book_dragon_client/theme/app_theme.dart';
import 'package:book_dragon_client/widgets/chat_bubble.dart';

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

const _token = 'test_token';

User _testUser({String dragonColor = 'moss'}) => User(
      id: 1,
      username: 'testReader',
      email: 'reader@book.dragon',
      createdAt: DateTime(2026, 1, 1),
      coins: 42,
      dragonId: 10,
      dragonName: 'Mossy',
      dragonColor: dragonColor,
    );

Map<String, dynamic> _tourneyJson({
  bool dailyComplete = false,
  int daysComplete = 3,
  int daysGoal = 10,
  String name = 'Summer Readers',
}) =>
    {
      'id': 42,
      'invite_code': 'ABC123',
      'name': name,
      'daily_progress': {
        'is_complete': dailyComplete,
        'minute_goal': 15,
        'minutes_complete': dailyComplete ? 15 : 5,
      },
      'overall_progress': {
        'day_number': daysComplete + 1,
        'days_complete': daysComplete,
        'days_goal': daysGoal,
        'is_complete': daysComplete >= daysGoal,
      },
      'taunt_messages': [
        'Get reading, squire!',
        'Thy pages await!',
        'A dragon reads more than thee!',
      ],
    };

Map<String, dynamic> _constantsJson() => {
      'overall_goal_days': [
        {'label': '3 days', 'value': 3},
        {'label': '1 week', 'value': 7},
      ],
      'daily_goal_minutes': [
        {'label': '15 minutes', 'value': 15},
        {'label': '30 minutes', 'value': 30},
      ],
    };

/// Builds a pumpable widget wrapping TourneyScreen with a mock HTTP backend.
Widget _buildApp({
  bool hasActiveTourney = false,
  bool dailyComplete = false,
  String dragonColor = 'moss',
  String tourneyName = 'Summer Readers',
}) {
  final mockClient = MockClient((req) async {
    if (req.url.path == '/constants') {
      return http.Response(jsonEncode(_constantsJson()), 200);
    }
    if (req.url.path == '/tourney' && req.method == 'GET') {
      if (!hasActiveTourney) {
        return http.Response('', 404);
      }
      return http.Response(
        jsonEncode(_tourneyJson(
          dailyComplete: dailyComplete,
          name: tourneyName,
        )),
        200,
      );
    }
    if (req.url.path == '/tourney' && req.method == 'POST') {
      return http.Response(jsonEncode(_tourneyJson()), 201);
    }
    if (req.url.path == '/join_tourney') {
      return http.Response(jsonEncode(_tourneyJson()), 200);
    }
    return http.Response('', 404);
  });

  // We need to inject the mock client into the TourneyScreen.
  // Since TourneyScreen creates its own ViewModel internally, we'll use
  // a _TestTourneyScreen that accepts a mock client for testability.
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: DefaultAssetBundle(
      bundle: TestAssetBundle(),
      child: _TestTourneyScreen(
        user: _testUser(dragonColor: dragonColor),
        token: _token,
        mockClient: mockClient,
      ),
    ),
  );
}

/// Thin wrapper around TourneyScreen logic for testability.
/// Replicates TourneyScreen's build but injects a mock HTTP client.
///
/// We test the ViewModel + View integration by reproducing the same widget
/// tree that TourneyScreen creates but with a controllable service layer.
class _TestTourneyScreen extends StatefulWidget {
  final User user;
  final String token;
  final MockClient mockClient;

  const _TestTourneyScreen({
    required this.user,
    required this.token,
    required this.mockClient,
  });

  @override
  State<_TestTourneyScreen> createState() => _TestTourneyScreenState();
}

class _TestTourneyScreenState extends State<_TestTourneyScreen> {
  @override
  Widget build(BuildContext context) {
    // Delegate to the real TourneyScreen — the mock is used via TourneyService
    // constructor injection. But TourneyScreen creates its ViewModel internally
    // (by design — scoped locally), so for widget tests we verify the overall
    // behavior by pumping the real screen and letting the mock backend drive it.
    return TourneyScreen(
      user: widget.user,
      token: widget.token,
      httpClient: widget.mockClient,
    );
  }
}

// ---------------------------------------------------------------------------
// Widget tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // No Challenge Active State
  // -------------------------------------------------------------------------

  group('No active challenge', () {
    testWidgets('shows plus button and no share button', (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Plus button should be present
      expect(find.byKey(const Key('tourney_add_button')), findsOneWidget);
      // Share button should NOT be present
      expect(find.byKey(const Key('tourney_share_button')), findsNothing);
    });

    testWidgets('shows "Tourney Hall" title', (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Tourney Hall'), findsOneWidget);
    });

    testWidgets('dragon asset is absent from widget tree', (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should not find the flying dragon image
      final flyingDragons = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage)
                .assetName
                .contains('dragons/flying'),
      );
      expect(flyingDragons, findsNothing);
    });

    testWidgets('tapping plus button opens JoinOrCreateDialog',
        (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('tourney_add_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Dialog should be visible with both tabs
      expect(find.text('Join Tourney'), findsOneWidget);
      expect(find.text('Create Tourney'), findsOneWidget);
      expect(find.text('Invite Code'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Challenge Active State
  // -------------------------------------------------------------------------

  group('Active challenge', () {
    testWidgets('shows share button and no plus button', (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('tourney_share_button')), findsOneWidget);
      expect(find.byKey(const Key('tourney_add_button')), findsNothing);
    });

    testWidgets('shows challenge name at top center', (tester) async {
      await tester.pumpWidget(_buildApp(
        hasActiveTourney: true,
        tourneyName: 'Summer Readers',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Summer Readers'), findsOneWidget);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows flying dragon with matching color', (tester) async {
      await tester.pumpWidget(_buildApp(
        hasActiveTourney: true,
        dragonColor: 'moss',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify a flying dragon image is present
      final flyingDragons = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage)
                .assetName
                .contains('dragons/flying/moss.png'),
      );
      expect(flyingDragons, findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Daily Completion States
  // -------------------------------------------------------------------------

  group('Daily completion states', () {
    testWidgets('daily incomplete — shows knight and taunt',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        hasActiveTourney: true,
        dailyComplete: false,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Knight image or fallback icon should be present
      final knightImages = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage)
                .assetName
                .contains('characters/knight'),
      );
      // Knight is rendered (image or error fallback)
      expect(
        knightImages.evaluate().isNotEmpty ||
            find.byIcon(Icons.shield).evaluate().isNotEmpty,
        isTrue,
      );

      // Chat bubble with first taunt should be visible
      expect(find.byType(ChatBubble), findsOneWidget);
      expect(find.text('Get reading, squire!'), findsOneWidget);
    });

    testWidgets('daily complete — hides knight and taunt', (tester) async {
      await tester.pumpWidget(_buildApp(
        hasActiveTourney: true,
        dailyComplete: true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Chat bubble should NOT be present
      expect(find.byType(ChatBubble), findsNothing);
      // Knight image should NOT be present
      final knightImages = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage)
                .assetName
                .contains('characters/knight'),
      );
      expect(knightImages, findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Dialog rendering
  // -------------------------------------------------------------------------

  group('JoinOrCreateDialog rendering', () {
    testWidgets('Join tab has invite code text field', (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open dialog
      await tester.tap(find.byKey(const Key('tourney_add_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Join tab (default first tab)
      expect(find.text('Invite Code'), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);
    });

    testWidgets('Create tab has name field and dropdowns', (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open dialog
      await tester.tap(find.byKey(const Key('tourney_add_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the Create tab
      await tester.tap(find.text('Create Tourney'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify form elements
      expect(find.text('Tournament Name'), findsOneWidget);
      expect(find.text('Daily Commitment'), findsOneWidget);
      expect(find.text('Overall Duration'), findsOneWidget);
      expect(find.text('Start Challenge'), findsOneWidget);
    });

    testWidgets('Start Challenge button is disabled when form empty',
        (tester) async {
      await tester.pumpWidget(_buildApp(hasActiveTourney: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open dialog
      await tester.tap(find.byKey(const Key('tourney_add_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the Create tab
      await tester.tap(find.text('Create Tourney'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the Start Challenge button
      final startButton = find.widgetWithText(ElevatedButton, 'Start Challenge');
      expect(startButton, findsOneWidget);

      // The button should be disabled (onPressed == null)
      final ElevatedButton button = tester.widget(startButton);
      expect(button.onPressed, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // ChatBubble widget
  // -------------------------------------------------------------------------

  group('ChatBubble widget', () {
    testWidgets('renders the text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ChatBubble(text: 'Hello, squire!'),
            ),
          ),
        ),
      );

      expect(find.text('Hello, squire!'), findsOneWidget);
      // We expect at least one CustomPaint (the tail), but we allow more from the environment
      expect(find.descendant(
        of: find.byType(ChatBubble),
        matching: find.byType(CustomPaint),
      ), findsOneWidget);
    });
  });
}
