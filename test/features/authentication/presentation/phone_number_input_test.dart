import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/features/authentication/presentation/screens/phone_number_screen.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

Future<void> _pumpPhoneInput(
  WidgetTester tester, {
  required ValueChanged<String> onSubmitted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: PhoneNumberInput(onPhoneSubmitted: onSubmitted),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('groups digits into 7XX XXX XXXX as typed', (tester) async {
    await _pumpPhoneInput(tester, onSubmitted: (_) {});

    await tester.enterText(find.byType(TextField), '7712345678');
    await tester.pump();

    expect(find.text('771 234 5678'), findsOneWidget);
  });

  testWidgets('shows live full-number preview while typing', (tester) async {
    await _pumpPhoneInput(tester, onSubmitted: (_) {});

    await tester.enterText(find.byType(TextField), '7712345678');
    await tester.pump();

    expect(find.textContaining('+964 771 234 5678'), findsOneWidget);
  });

  testWidgets('shows invalid message for a short number', (tester) async {
    await _pumpPhoneInput(tester, onSubmitted: (_) {});

    await tester.enterText(find.byType(TextField), '771');
    await tester.pump();

    await tester.tap(find.text('Send Code'));
    await tester.pump();

    expect(find.textContaining('Phone must be'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('submits the full +964 number when valid', (tester) async {
    String? submitted;
    await _pumpPhoneInput(tester, onSubmitted: (v) => submitted = v);

    await tester.enterText(find.byType(TextField), '7712345678');
    await tester.pump();

    await tester.tap(find.text('Send Code'));
    await tester.pump();

    expect(submitted, '+9647712345678');
  });
}