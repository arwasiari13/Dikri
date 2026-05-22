import 'package:flutter_test/flutter_test.dart';

import 'package:dikri/main.dart';

void main() {
  testWidgets('app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const DikriApp());
    await tester.pump();

    expect(find.byType(DikriApp), findsOneWidget);
  });
}
