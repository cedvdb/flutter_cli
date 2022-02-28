import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Container(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    await Future.delayed(const Duration(seconds: 10));
  });
}
