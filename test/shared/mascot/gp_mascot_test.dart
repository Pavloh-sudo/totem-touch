import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/shared/mascot/gp_mascot.dart';

void main() {
  testWidgets('GP cambia de estado y contexto sin depender del dibujo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GpMascot(
            state: GpMascotState.celebrate,
            mascotContext: GpMascotContext.careers,
            artwork: Text('GP'),
          ),
        ),
      ),
    );

    expect(find.text('GP'), findsOneWidget);
    expect(find.byKey(const ValueKey('celebrate-careers')), findsOneWidget);
  });
}
