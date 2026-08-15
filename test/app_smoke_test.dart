import 'package:battery_tracker/app/battery_tracker_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starter application shell renders', (tester) async {
    await tester.pumpWidget(const BatteryTrackerApp());

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Batteries'), findsOneWidget);
    expect(find.text('Battery Sets'), findsOneWidget);
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('QR Labels'), findsOneWidget);
  });
}
