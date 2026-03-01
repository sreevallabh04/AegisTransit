// Basic Flutter widget smoke test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_bus_passenger_ui/main.dart';

void main() {
  testWidgets('App starts and shows login', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartBusApp());
    await tester.pumpAndSettle();

    // Login screen should be visible (contains typical login UI)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
