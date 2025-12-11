import 'package:fitness_app_pro/main.dart'; // keep only this
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard is displayed', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const FitnessAppPro());

    // Verify that DashboardPage title exists
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

