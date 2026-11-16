import 'package:flutter_test/flutter_test.dart';

import 'package:builza/app.dart';

void main() {
  testWidgets('Screen 1 shows BUILZA login', (tester) async {
    await tester.pumpWidget(const BuilzaApp(firebaseReady: false));

    expect(find.bySemanticsLabel('BUILZA'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Register a company'), findsOneWidget);
    expect(find.text('Connect Firebase'), findsNothing);

    await tester.tap(find.text('Register a company'));
    await tester.pumpAndSettle();
    expect(find.text('Company name'), findsOneWidget);
    expect(find.text('Company logo'), findsOneWidget);
  });
}
