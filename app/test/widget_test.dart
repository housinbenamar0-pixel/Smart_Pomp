import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartpumpmonitor/main.dart';

void main() {
  testWidgets('AppLoader affiche l\'écran de chargement', (WidgetTester tester) async {
    await tester.pumpWidget(const AppLoader());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
