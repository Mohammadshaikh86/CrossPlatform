import 'package:flutter_test/flutter_test.dart';
import 'package:ridesharex/main.dart';

void main() {
  testWidgets('RideShareX App loads dashboard and header', (WidgetTester tester) async {
    await tester.pumpWidget(const RideShareXApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify app title is present
    expect(find.text('RideShareX'), findsOneWidget);
  });
}
