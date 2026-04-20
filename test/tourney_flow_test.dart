import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/models/user.dart';
import 'package:book_dragon_client/screens/tourney_screen.dart';
import 'package:book_dragon_client/theme/app_theme.dart';
import 'package:book_dragon_client/widgets/chat_bubble.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

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

Map<String, dynamic> _tourneyJson({
  String name = 'Summer Readers',
  bool dailyComplete = false,
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
        'day_number': 1,
        'days_complete': 0,
        'days_goal': 7,
        'is_complete': false,
      },
      'taunt_messages': [
        'Get reading, squire!',
      ],
    };

Map<String, dynamic> _constantsJson() => {
      'tourney_config': {
        'overall_goal_days': [
          {'label': '3 days', 'value': 3},
          {'label': '1 week', 'value': 7},
        ],
        'daily_goal_minutes': [
          {'label': '15 minutes', 'value': 15},
          {'label': '30 minutes', 'value': 30},
        ],
      }
    };

Widget _buildApp({required MockClient mockClient}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: DefaultAssetBundle(
      bundle: TestAssetBundle(),
      child: TourneyScreen(
        user: _testUser(),
        token: 'test_token',
        httpClient: mockClient,
      ),
    ),
  );
}

/// Helper for pumping and waiting for initialization.
Future<void> _pumpForInitialization(WidgetTester tester) async {
  await tester.pump();
  // Allow time for initialization
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Tourney Flow', () {
    testWidgets('Complete "Create Tourney" flow from empty hall', (tester) async {
      bool hasActiveTourney = false;
      String tournamentName = 'Epic Quest';

      final mockClient = MockClient((req) async {
        if (req.url.path == '/constants') {
          return http.Response(jsonEncode(_constantsJson()), 200);
        }
        if (req.url.path == '/tourney' && req.method == 'GET') {
          if (!hasActiveTourney) {
            return http.Response('', 404);
          }
          return http.Response(jsonEncode(_tourneyJson(name: tournamentName)), 200);
        }
        if (req.url.path == '/tourney' && req.method == 'POST') {
          hasActiveTourney = true;
          final body = jsonDecode(req.body);
          tournamentName = body['name'];
          return http.Response(jsonEncode(_tourneyJson(name: tournamentName)), 201);
        }
        return http.Response('', 404);
      });

      // 1. Load screen with no tourney
      await tester.pumpWidget(_buildApp(mockClient: mockClient));
      await _pumpForInitialization(tester);

      expect(find.text('Tourney Hall'), findsOneWidget);
      expect(find.byKey(const Key('tourney_add_button')), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // 2. Open JoinOrCreateDialog
      await tester.tap(find.byKey(const Key('tourney_add_button')));
      await tester.pumpAndSettle();

      expect(find.text('Join Tourney'), findsOneWidget);
      expect(find.text('Create Tourney'), findsOneWidget);

      // 3. Switch to Create tab
      await tester.tap(find.text('Create Tourney'));
      await tester.pumpAndSettle();

      expect(find.text('Tournament Name'), findsOneWidget);
      
      // 4. Fill in the form
      await tester.enterText(
        find.widgetWithText(TextField, 'Tournament Name'),
        'Epic Quest',
      );
      await tester.pumpAndSettle();

      // Find the dropdowns and select values
      // Note: DropdownButtonFormField is a bit tricky to interact with in tests
      // We need to tap the dropdown, then tap the item in the overlay.
      
      // Select Daily Commitment
      await tester.tap(find.text('Daily Commitment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15 minutes').last);
      await tester.pumpAndSettle();

      // Select Overall Duration
      await tester.tap(find.text('Overall Duration'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 week').last);
      await tester.pumpAndSettle();

      // 5. Verify button is enabled and tap it
      final startButton = find.widgetWithText(ElevatedButton, 'Start Challenge');
      expect(tester.widget<ElevatedButton>(startButton).onPressed, isNotNull);
      
      await tester.tap(startButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 6. Verify hall is updated
      // We need to pump another frame or two for the TourneyScreen to refresh after dialog closes
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Epic Quest'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(ChatBubble), findsOneWidget);
      expect(find.text('Get reading, squire!'), findsOneWidget);
      
      // Flying dragon should also be there
      final flyingDragons = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('dragons/flying'),
      );
      expect(flyingDragons, findsOneWidget);
    });

    testWidgets('Complete "Join Tourney" flow from empty hall', (tester) async {
      bool hasActiveTourney = false;
      const inviteCode = 'JOINME123';

      final mockClient = MockClient((req) async {
        if (req.url.path == '/constants') {
          return http.Response(jsonEncode(_constantsJson()), 200);
        }
        if (req.url.path == '/tourney' && req.method == 'GET') {
          if (!hasActiveTourney) {
            return http.Response('', 404);
          }
          return http.Response(jsonEncode(_tourneyJson(name: 'Joined Quest')), 200);
        }
        if (req.url.path == '/join_tourney' && req.method == 'POST') {
          final body = jsonDecode(req.body);
          if (body['invite_code'] == inviteCode) {
            hasActiveTourney = true;
            return http.Response(jsonEncode(_tourneyJson(name: 'Joined Quest')), 200);
          }
          return http.Response('{"error": "Invalid code"}', 400);
        }
        return http.Response('', 404);
      });

      // 1. Load screen with no tourney
      await tester.pumpWidget(_buildApp(mockClient: mockClient));
      await _pumpForInitialization(tester);

      // 2. Open JoinOrCreateDialog
      await tester.tap(find.byKey(const Key('tourney_add_button')));
      await tester.pumpAndSettle();

      // 3. Enter invalid code
      await tester.enterText(find.widgetWithText(TextField, 'Invite Code'), 'WRONG');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Join'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.textContaining('400'), findsWidgets);

      // 4. Enter valid code
      await tester.enterText(find.widgetWithText(TextField, 'Invite Code'), inviteCode);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Join'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 5. Verify hall is updated
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Joined Quest'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
