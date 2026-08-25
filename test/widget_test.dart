import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/app.dart';

void main() {
  testWidgets('muestra la bienvenida de GPA', (tester) async {
    await tester.pumpWidget(const TotemTouchApp());
    await tester.pumpAndSettle();

    expect(find.text('Descubre todo lo que hacemos en GPA'), findsOneWidget);
    expect(find.text('Todo en un solo lugar'), findsOneWidget);
    expect(find.byKey(const ValueKey('technical-background')), findsOneWidget);
  });
}
