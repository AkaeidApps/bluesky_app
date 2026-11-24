import 'package:flutter_test/flutter_test.dart';
import 'package:bluesky_app/main.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';

void main() {
  testWidgets('AuraApp smoke test and brand mark rendering', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AuraApp());
    expect(find.byType(AuraBrandMark), findsWidgets);
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
