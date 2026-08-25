import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/app.dart';
import 'package:totem_touch/shared/mascot/gp_mascot.dart';

void main() {
  testWidgets('muestra la bienvenida de GPA', (tester) async {
    await tester.pumpWidget(const TotemTouchApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Descubre todo lo que hacemos en GPA'), findsOneWidget);
    expect(find.text('Quiero conocer más'), findsOneWidget);
    expect(find.byType(GpMascot), findsOneWidget);
    expect(find.byKey(const ValueKey('technical-background')), findsOneWidget);
  });
}
