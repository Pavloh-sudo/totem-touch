import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosco_gpa/app/app.dart';
import 'package:kiosco_gpa/core/animations/app_motion.dart';
import 'package:kiosco_gpa/core/session/registration_session_controller.dart';
import 'package:kiosco_gpa/shared/buttons/gpa_buttons.dart';
import 'package:kiosco_gpa/shared/mascot/gp_mascot.dart';

void main() {
  Future<void> waitForPreload(WidgetTester tester) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const ValueKey('technical-splash')).evaluate().isEmpty) {
        return;
      }
    }
    fail('La precarga inicial no terminó.');
  }

  testWidgets('muestra la bienvenida de GPA', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const KioscoGpaApp());
    expect(find.byKey(const ValueKey('technical-splash')), findsOneWidget);
    await waitForPreload(tester);
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

    await tester.pumpWidget(const KioscoGpaApp());
    await waitForPreload(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    final sessionController = tester
        .widget<RegistrationSessionScope>(find.byType(RegistrationSessionScope))
        .notifier!;
    final preparedId = sessionController.nextSessionId;
    await tester.tap(find.text('Quiero conocer más'));
    await tester.pump();
    final overlapProbe =
        AppMotion.attractExit -
        AppMotion.attractOverlap +
        const Duration(milliseconds: 30);
    await tester.pump(overlapProbe);

    final attractOpacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('attract-exit-opacity')),
    );
    final registrationOpacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('registration-entry-opacity')),
    );
    expect(attractOpacity.opacity, inExclusiveRange(0, 1));
    expect(registrationOpacity.opacity, inExclusiveRange(0, 1));

    await tester.pump(AppMotion.attractToRegistration - overlapProbe);
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
    await tester.pump(AppMotion.attractToRegistration);
    expect(sessionController.current, isNull);
    expect(sessionController.nextSessionId, isNot(preparedId));
  });

  testWidgets('el acceso administrativo requiere mantener el logo y usar PIN', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const KioscoGpaApp());
    await waitForPreload(tester);

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
    expect(find.text('Revisar estados'), findsOneWidget);
    expect(find.text('Reiniciar registros de prueba'), findsOneWidget);
    expect(find.text('Volver al kiosco'), findsOneWidget);
    expect(find.textContaining('se conectará después'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
