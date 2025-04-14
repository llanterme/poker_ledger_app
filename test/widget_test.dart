import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_ledger/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: PokerLedgerApp()));

    // Verify that the app initializes without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
