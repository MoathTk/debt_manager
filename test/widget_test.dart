import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_debt_management/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DebtManagementApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Debt Management'), findsOneWidget);
  });
}
