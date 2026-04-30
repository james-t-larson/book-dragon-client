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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_dragon_client/blocs/book/book_bloc.dart';
import 'package:book_dragon_client/blocs/book/book_event.dart';
import 'package:book_dragon_client/repositories/book_repository.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.startsWith('assets/')) {
      return ByteData.view(Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
      ]).buffer);
    }
    return rootBundle.load(key);
  }
}

void main() {
  late User dummyUser;

  setUp(() {
    dummyUser = User(
      id: 1,
      username: 'test',
      email: 'test@example.com',
      createdAt: DateTime.now(),
      coins: 100,
      dragonColor: 'red',
      dragonId: 1,
    );
  });

  final mockClient = MockClient((req) async {
    if (req.url.path.contains('/books')) {
      return http.Response(jsonEncode([{
        'id': 1,
        'title': 'Test Scroll',
        'author': 'Test Author',
        'genre': 'Test Genre',
        'total_pages': 100,
        'current_page': 50,
        'reading': true,
      }]), 200);
    }
    return http.Response('', 404);
  });

  Widget buildTestApp(MockClient client, {bool isActive = true}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: BlocProvider<BookBloc>(
          create: (_) => BookBloc(
            repository: BookRepository(httpClient: client),
            initialBooks: [],
          )..add(const FetchActiveBooks('test_token')),
          child: FocusTimerScreen(
            user: dummyUser,
            token: 'test_token',
            isActive: isActive,
            httpClient: client,
          ),
        ),
      ),
    );
  }

  group('Focus Timer States Content', () {
    testWidgets('Initial State - Configuration', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(buildTestApp(mockClient));

      await tester.pumpAndSettle();

      // Verify Configuration state options are present
      expect(find.text('Chosen Scroll'), findsOneWidget);
      expect(find.text('Test Scroll'), findsOneWidget);
      expect(find.text('Select Duration'), findsOneWidget);
      expect(find.text('15:00'), findsOneWidget); // Default time
      expect(find.text('Start Focus'), findsOneWidget);
    });

    testWidgets('Taps "Start Focus" -> Shows WarningDialog', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hide_focus_loss_warning': false});

      await tester.pumpWidget(buildTestApp(mockClient));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Focus'));
      await tester.pumpAndSettle();

      // Verify WarningDialog corresponds to state chart
      expect(find.text('Focus Warning'), findsOneWidget);
      expect(find.text('If you leave the page for any reason, the timer will stop and any coins will be lost.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Start Timer'), findsOneWidget);
    });

    testWidgets('WarningDialog -> Taps "Cancel" -> Reverts to Configuration', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hide_focus_loss_warning': false});

      await tester.pumpWidget(buildTestApp(mockClient));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Focus'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog is gone, back to config
      expect(find.text('Focus Warning'), findsNothing);
      expect(find.text('Select Duration'), findsOneWidget); // We are back to configuration
    });

    testWidgets('WarningDialog -> Confirms Warning -> Countdown Running State -> User Abort (Surrender) -> Configuration', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hide_focus_loss_warning': false});

      await tester.pumpWidget(buildTestApp(mockClient));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Focus'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Timer'));
      await tester.pumpAndSettle();

      // Now in Countdown state
      expect(find.text('Select Duration'), findsNothing); // Config hidden
      expect(find.text('Studying: Test Scroll'), findsOneWidget);
      expect(find.text('Surrender'), findsOneWidget);

      // Surrender (User Abort)
      await tester.tap(find.text('Surrender'));
      await tester.pumpAndSettle();

      // Back to Configuration state
      expect(find.text('Select Duration'), findsOneWidget);
      expect(find.text('Start Focus'), findsOneWidget);
      expect(find.text('Surrender'), findsNothing);
    });

    testWidgets('Countdown -> isActive changes from true to false -> FocusLostPenalty -> Configuration', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hide_focus_loss_warning': true});

      await tester.pumpWidget(buildTestApp(mockClient));

      await tester.pumpAndSettle();

      // Start Focus immediately (warning is hidden)
      await tester.tap(find.text('Start Focus'));
      await tester.pumpAndSettle();

      // Now in Countdown
      expect(find.text('Surrender'), findsOneWidget);

      // Trigger FocusLostPenalty via navigation (isActive: false)
      await tester.pumpWidget(buildTestApp(mockClient, isActive: false));
      
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verified: penalty triggered, back to Config
      expect(find.text('Select Duration'), findsOneWidget);
    });
  });
}
