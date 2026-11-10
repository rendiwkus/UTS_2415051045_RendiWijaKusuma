import 'package:flutter_test/flutter_test.dart';
import 'package:uts_2415051045_rendiwijakusuma/main.dart';

void main() {
  testWidgets('App smoke test loads REFARM AgroStore', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('REFARM AgroStore'), findsOneWidget);
  });
}
