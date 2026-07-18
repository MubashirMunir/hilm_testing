import 'package:flutter_test/flutter_test.dart';
import 'package:hilm_flutter_website/main.dart';

void main() {
  testWidgets('HILM home page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HilmApp());
    await tester.pump();

    expect(find.text('HILM Institute'), findsWidgets);
    expect(find.text('Browse Course Catalog'), findsOneWidget);
  });
}
