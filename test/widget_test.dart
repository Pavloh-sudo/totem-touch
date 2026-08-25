import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/app.dart';
import 'package:totem_touch/shared/buttons/gpa_buttons.dart';
import 'package:totem_touch/shared/mascot/gp_mascot.dart';

void main() {
  testWidgets('muestra la bienvenida de GPA', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TotemTouchApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Tu siguiente idea puede empezar aquí.'), findsOneWidget);
    expect(
      find.textContaining('Conoce nuestras soluciones, oportunidades'),
      findsOneWidget,
    );
    expect(find.text('Quiero conocer más'), findsOneWidget);
    expect(find.byType(GpMascot), findsOneWidget);
    expect(find.byKey(const ValueKey('technical-background')), findsOneWidget);

    final logo = find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == 'GPA',
    );
    expect(tester.getSize(logo), const Size(180, 180));
    expect(tester.widget<GpMascot>(find.byType(GpMascot)).size, 310);
    expect(tester.getSize(find.byType(GpaPrimaryButton)), const Size(280, 68));
  });

  testWidgets('solapa la salida de attract con la entrada del registro', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TotemTouchApp());
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.tap(find.text('Quiero conocer más'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));

    final attractOpacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('attract-exit-opacity')),
    );
    final registrationOpacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('registration-entry-opacity')),
    );
    expect(attractOpacity.opacity, inExclusiveRange(0, 1));
    expect(registrationOpacity.opacity, inExclusiveRange(0, 1));

    await tester.pump(const Duration(milliseconds: 210));
    expect(find.text('Cuéntanos un poco sobre ti'), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('registration-entry-opacity')),
          )
          .opacity,
      1,
    );
  });
}
