import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/app.dart';

void main() {
  testWidgets('muestra la pantalla base del tótem', (tester) async {
    await tester.pumpWidget(const TotemTouchApp());
    await tester.pumpAndSettle();

    expect(find.text('Tótem interactivo\nGPA'), findsOneWidget);
    expect(find.text('Flutter Web · 1024 × 768'), findsOneWidget);
  });
}
