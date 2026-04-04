// Smoke test
import 'package:flutter_test/flutter_test.dart';
import 'package:book_dragon_client/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const BookDragonApp());
    expect(find.byType(BookDragonApp), findsOneWidget);
  });
}
