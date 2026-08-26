import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/app.dart';
import 'package:totem_touch/core/session/registration_session_controller.dart';
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
    final sessionController = tester
        .widget<RegistrationSessionScope>(find.byType(RegistrationSessionScope))
        .notifier!;
    final preparedId = sessionController.nextSessionId;
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
    expect(find.text('Primero, queremos conocerte.'), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('registration-entry-opacity')),
          )
          .opacity,
      1,
    );
    expect(sessionController.current?.sessionId, preparedId);

    await tester.tap(find.text('Volver'));
    await tester.pump(const Duration(milliseconds: 330));
    expect(sessionController.current, isNull);
    expect(sessionController.nextSessionId, isNot(preparedId));
  });

  testWidgets('el acceso administrativo requiere mantener el logo y usar PIN', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpWidget(const TotemTouchApp());
    await tester.pump();

    final logo = find.bySemanticsLabel('GPA');
    final gesture = await tester.startGesture(tester.getCenter(logo));
    await tester.pump(const Duration(seconds: 4, milliseconds: 999));
    expect(find.text('Acceso administrativo'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Acceso administrativo'), findsOneWidget);
    await gesture.up();

    await tester.tap(find.text('2'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('6'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 280));

    expect(find.text('Administración'), findsOneWidget);
    expect(find.text('Exportar Excel'), findsOneWidget);
    expect(find.text('Probar conexión'), findsOneWidget);
    expect(find.text('Volver al kiosco'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
