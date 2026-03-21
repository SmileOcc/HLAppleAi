import 'package:flutter_test/flutter_test.dart';
import 'package:hl_apple_ai/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HLAppleAiApp());
    await tester.pumpAndSettle();
    expect(find.text('HLAppleAi'), findsOneWidget);
  });
}
