import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/kiosk_shell.dart';
import 'package:totem_touch/core/animations/app_motion.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';
import 'package:totem_touch/features/registration/presentation/registration_page.dart';
import 'package:totem_touch/shared/buttons/gpa_buttons.dart';
import 'package:totem_touch/shared/inputs/gpa_consent_checkbox.dart';
import 'package:totem_touch/shared/inputs/gpa_touch_field.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  Future<void> tapKeys(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await tester.tap(find.text(key).last);
      await tester.pump();
    }
  }

  Finder field(String label) {
    return find.widgetWithText(GpaTouchField, label);
  }

  testWidgets('completa los dos paneles usando el teclado del tótem', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    final engine = FakeSoundPlaybackEngine();
    final soundController = SoundController(engine: engine);
    addTearDown(soundController.dispose);
    await soundController.unlock();
    VisitorRegistration? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          soundController: soundController,
          inactivityTimeout: null,
          child: RegistrationPage(
            onBack: () {},
            onContinue: (registration) async {
              result = registration;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Primero, queremos conocerte.'), findsOneWidget);
    expect(
      find.text(
        'Déjanos tus datos para personalizar la información que encontrarás.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<GpaPrimaryButton>(
            find.widgetWithText(GpaPrimaryButton, 'Continuar'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Estudiante'));
    await tester.pump();
    expect(find.text('Escuela / Institución'), findsOneWidget);

    await tester.tap(field('Nombre'));
    await tester.pump();
    await tester.pump(AppMotion.keyboardShow);
    await tapKeys(tester, ['P', 'A', 'B', 'L', 'O']);

    await tester.tap(field('Escuela / Institución'));
    await tester.pump();
    await tapKeys(tester, ['G', 'P', 'A']);

    expect(
      tester
          .widget<GpaPrimaryButton>(
            find.widgetWithText(GpaPrimaryButton, 'Continuar'),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.pump(AppMotion.standard);

    expect(find.text('Queremos conocerte'), findsOneWidget);
    expect(
      find.text('¿Dónde podemos compartirte información?'),
      findsOneWidget,
    );
    expect(
      tester.widget<GpaConsentCheckbox>(find.byType(GpaConsentCheckbox)).value,
      isFalse,
    );

    await tester.tap(field('Correo electrónico'));
    await tester.pump();
    await tester.pump(AppMotion.keyboardShow);
    await tapKeys(tester, ['P']);
    expect(find.text('Revisa el correo antes de continuar.'), findsNothing);
    await tester.tap(find.text('123'));
    await tester.pump();
    await tapKeys(tester, ['1']);
    expect(find.text('Revisa el correo antes de continuar.'), findsNothing);
    for (final domain in [
      '@gmail.com',
      '@hotmail.com',
      '@outlook.com',
      '@yahoo.com',
      '@icloud.com',
    ]) {
      expect(find.text(domain), findsOneWidget);
    }
    expect(find.text('@live.com'), findsNothing);
    await tapKeys(tester, ['@gmail.com']);

    await tester.tap(field('Teléfono'));
    await tester.pump();
    await tapKeys(tester, List.filled(10, '1'));

    expect(
      tester
          .widget<GpaPrimaryButton>(
            find.widgetWithText(GpaPrimaryButton, 'Continuar'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(GpaConsentCheckbox));
    await tester.pump(AppMotion.checkboxCheck);
    expect(
      tester.widget<GpaConsentCheckbox>(find.byType(GpaConsentCheckbox)).value,
      isTrue,
    );

    final continueButton = find.widgetWithText(GpaPrimaryButton, 'Continuar');
    expect(
      tester.widget<GpaPrimaryButton>(continueButton).onPressed,
      isNotNull,
    );
    await tester.tap(continueButton);
    await tester.pump();
    await tester.pump(
      AppMotion.keyboardHide +
          AppMotion.keyboardToScreen -
          const Duration(milliseconds: 1),
    );
    expect(result, isNull);
    await tester.pump(const Duration(milliseconds: 1));

    expect(result, isNotNull);
    expect(result!.profile, VisitorProfile.student);
    expect(result!.name, 'Pablo');
    expect(result!.organization, 'Gpa');
    expect(result!.email, 'p1@gmail.com');
    expect(result!.phone, '1111111111');
    expect(result!.acceptsInformation, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no muestra un aviso de privacidad inexistente', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          soundController: controller,
          inactivityTimeout: null,
          child: RegistrationPage(onBack: () {}, onContinue: (_) async {}),
        ),
      ),
    );

    await tester.tap(find.text('Otro'));
    await tester.tap(field('Nombre'));
    await tester.pump();
    await tester.pump(AppMotion.keyboardShow);
    await tapKeys(tester, ['A']);
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.pump(AppMotion.standard);
    expect(find.textContaining('aviso de privacidad'), findsNothing);
    expect(
      find.byKey(const ValueKey('registration-contact-panel')),
      findsOneWidget,
    );
  });

  testWidgets('bloquea correos y teléfonos incompletos con mensajes claros', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          soundController: controller,
          inactivityTimeout: null,
          child: RegistrationPage(onBack: () {}, onContinue: (_) async {}),
        ),
      ),
    );

    await tester.tap(find.text('Otro'));
    await tester.tap(field('Nombre'));
    await tester.pump();
    await tester.pump(AppMotion.keyboardShow);
    await tapKeys(tester, ['A']);
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.pump(AppMotion.standard);

    await tester.tap(field('Correo electrónico'));
    await tester.pump();
    await tester.pump(AppMotion.keyboardShow);
    await tapKeys(tester, ['P']);
    await tester.tap(field('Teléfono'));
    await tester.pump();
    expect(find.text('Revisa el correo antes de continuar.'), findsOneWidget);

    await tapKeys(tester, List.filled(5, '1'));
    await tester.tap(field('Correo electrónico'));
    await tester.pump();
    expect(find.text('Revisa el teléfono antes de continuar.'), findsOneWidget);
    expect(
      tester
          .widget<GpaPrimaryButton>(
            find.widgetWithText(GpaPrimaryButton, 'Continuar'),
          )
          .onPressed,
      isNull,
    );
  });
}
