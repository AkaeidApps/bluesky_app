import 'package:flutter_test/flutter_test.dart';
import 'package:bluesky_app/main.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';

void main() {
  testWidgets('AuraApp smoke test and navigation to onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AuraApp());
    expect(find.byType(AuraBrandMark), findsWidgets);

    // Let the splash screen timer finish and transition
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text("See what's next."), findsOneWidget);
    expect(find.text('Create a new account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
