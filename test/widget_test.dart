import 'package:flutter_test/flutter_test.dart';
import 'package:clock_flutter/main.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  testWidgets('App loads and shows map', (WidgetTester tester) async {
    tz.initializeTimeZones();
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WorldClockApp());

    // Verify that the AppBar title is correct.
    expect(find.text('World Clock Map'), findsOneWidget);

    // Verify that the FlutterMap is present.
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
