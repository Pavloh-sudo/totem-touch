import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/animations/app_motion.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';
import 'package:totem_touch/features/interests/domain/interest_area.dart';
import 'package:totem_touch/features/interests/presentation/interests_screen.dart';
import 'package:totem_touch/features/interests/presentation/widgets/interest_area_card.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  const registration = VisitorRegistration(
    profile: VisitorProfile.professional,
    name: 'Pablo',
    organization: '',
    email: 'pablo1@correo.com',
    phone: '1111111111',
    acceptsInformation: false,
  );

  Future<void> pumpScreen(
    WidgetTester tester, {
    Future<void> Function(InterestArea area)? onSelected,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: InterestsScreen(
          registration: registration,
          onBack: () {},
          onSelected: onSelected,
        ),
      ),
    );
  }

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets('acomoda las seis áreas en una cuadrícula de 3 por 2', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pump(
      (AppMotion.interestCardStagger * 5) + AppMotion.interestCardEntry,
    );

    expect(find.text('¿Qué te gustaría explorar?'), findsOneWidget);
    expect(find.text('Elige el área que más te interesa.'), findsOneWidget);
    for (final area in InterestArea.values) {
      expect(find.text(area.title), findsOneWidget);
      expect(find.text(area.description), findsOneWidget);
    }

    final cards = find.byType(InterestAreaCard);
    expect(cards, findsNWidgets(6));
    expect(tester.getSize(cards.first), const Size(296, 166));
    expect(tester.takeException(), isNull);
  });

  testWidgets('las tarjetas entran con 35 ms de diferencia', (tester) async {
    await pumpScreen(tester);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 32));

    final firstOpacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('interest-entry-robotics')),
    );
    final secondOpacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('interest-entry-cutting')),
    );
    expect(firstOpacity.opacity, greaterThan(0));
    expect(secondOpacity.opacity, 0);
  });

  testWidgets('selecciona, atenúa las demás y cambia el contexto de GP', (
    tester,
  ) async {
    InterestArea? result;
    await pumpScreen(tester, onSelected: (area) async => result = area);
    await tester.pump(
      (AppMotion.interestCardStagger * 5) + AppMotion.interestCardEntry,
    );

    await tester.tap(find.text(InterestArea.robotics.title));
    await tester.pump();

    InterestAreaCard card(InterestArea area) {
      return tester.widget<InterestAreaCard>(
        find.ancestor(
          of: find.text(area.title),
          matching: find.byType(InterestAreaCard),
        ),
      );
    }

    expect(card(InterestArea.robotics).selected, isTrue);
    expect(card(InterestArea.cutting).dimmed, isTrue);
    expect(
      find.byKey(const ValueKey('gp-head-accessory-robotics')),
      findsOneWidget,
    );

    await tester.pump(
      AppMotion.interestUnselected - const Duration(milliseconds: 1),
    );
    expect(result, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(result, InterestArea.robotics);
  });
}
