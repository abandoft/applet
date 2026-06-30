import 'package:applet/applet.dart';
import 'package:example/main.dart' as app;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitForText(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text(text).evaluate().isNotEmpty) {
        return;
      }
    }
    expect(find.text(text), findsOneWidget);
  }

  testWidgets('material 3 demo navigation and actions work in the real app', (
    tester,
  ) async {
    app.main();
    await waitForText(tester, 'Material 3');

    await tester.tap(find.text('Color').first);
    await tester.pumpAndSettle();
    await waitForText(tester, 'Light ColorScheme');

    await tester.tap(find.text('Components').first);
    await tester.pumpAndSettle();
    await waitForText(tester, 'Buttons');

    await tester.scrollUntilVisible(
      find.text('Show snackbar'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Show snackbar'));
    await waitForText(tester, 'This is a snackbar');
  });

  testWidgets('module default export can use concise material import', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Applet.source('''
import "@app/material";

export default function App() {
  const count = State(0);

  return MaterialApp({
    debugShowCheckedModeBanner: false,
    home: Scaffold({
      body: Center(
        VStack(
          Text("Count: " + count),
          Button("Add").onTap(() => count.update((value) => value + 1))
        ).gap(12).min()
      ),
    }),
  });
}
'''),
    );
    await waitForText(tester, 'Count: 0');

    await tester.tap(find.text('Add'));
    await waitForText(tester, 'Count: 1');
  });
}
