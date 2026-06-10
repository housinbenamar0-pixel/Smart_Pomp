import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartpumpmonitor/main.dart';

void main() {
  testWidgets('SmartPumpMonitor app test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartPumpMonitorApp());
    expect(find.text('SmartPumpMonitor'), findsOneWidget);
  });
}