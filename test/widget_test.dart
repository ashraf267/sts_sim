import 'package:flutter_test/flutter_test.dart';
import 'package:sts_sim/main.dart';

void main() {
  testWidgets('STS App launches and displays main dashboard title', (WidgetTester tester) async {
    await tester.pumpWidget(const StsSimApp());
    expect(find.text('STS Prepaid Meter Simulator'), findsOneWidget);
  });
}
