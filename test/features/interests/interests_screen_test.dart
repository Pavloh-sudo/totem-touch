import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/animations/app_motion.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/features/interests/domain/interest_tree.dart';
import 'package:totem_touch/features/interests/presentation/interests_screen.dart';
import 'package:totem_touch/features/interests/presentation/widgets/interest_option_card.dart';
import 'package:totem_touch/features/interests/presentation/widgets/interest_options_grid.dart';
import 'package:totem_touch/shared/feedback/gpa_progress_indicator.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    ValueChanged<List<List<String>>>? onContinue,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: InterestsScreen(
          onBack: () {},
          onContinue: onContinue ?? (_) {},
          onSessionExpired: () {},
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
    expect(find.text('Elige un área para ver sus opciones.'), findsOneWidget);
    for (final node in InterestTree.roots) {
      expect(find.text(node.title), findsOneWidget);
      expect(find.text(node.description), findsOneWidget);
    }

    final cards = find.byType(InterestOptionCard);
    expect(cards, findsNWidgets(6));
    expect(tester.getSize(cards.first), const Size(296, 166));
    expect(tester.takeException(), isNull);
  });

  testWidgets('abre los once hijos con breadcrumb, detalle y grid compacto', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pump(
      (AppMotion.interestCardStagger * 5) + AppMotion.interestCardEntry,
    );

    final robotics = InterestTree.roots.first;
    await tester.tap(find.text(robotics.title));
    await tester.pump(AppMotion.interestUnselected + AppMotion.screen);
    await tester.pump(
      (AppMotion.interestCardStagger * 10) + AppMotion.interestCardEntry,
    );

    expect(find.text(robotics.title), findsOneWidget);
    expect(find.text('¿Qué opciones te interesan?'), findsOneWidget);
    expect(find.text('Puedes elegir más de una opción.'), findsOneWidget);
    for (final node in robotics.children) {
      expect(find.text(node.title), findsOneWidget);
    }
    final cards = find.byType(InterestOptionCard);
    expect(cards, findsNWidgets(11));
    expect(tester.getSize(cards.first), const Size(221.5, 132));
    expect(
      tester
          .widget<GpaProgressIndicator>(find.byType(GpaProgressIndicator))
          .stage,
      KioskProgressStage.detail,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'permite seleccionar y deseleccionar sin modal y pregunta al volver',
    (tester) async {
      List<List<String>>? result;
      await pumpScreen(tester, onContinue: (paths) => result = paths);
      await tester.pump(
        (AppMotion.interestCardStagger * 5) + AppMotion.interestCardEntry,
      );

      final cutting = InterestTree.roots[1];
      await tester.tap(find.text(cutting.title));
      await tester.pump(AppMotion.interestUnselected + AppMotion.screen);
      await tester.pump(
        (AppMotion.interestCardStagger * 3) + AppMotion.interestCardEntry,
      );
      final leaf = cutting.children.first;
      final secondLeaf = cutting.children[1];

      await tester.tap(find.text(leaf.title));
      await tester.tap(find.text(leaf.title));
      await tester.pump(
        AppMotion.interestUnselected + AppMotion.interestFeedback,
      );

      expect(find.byKey(const ValueKey('interest-explore-more')), findsNothing);
      expect(
        find.byKey(const ValueKey('interest-selection-count')),
        findsOneWidget,
      );
      await tester.tap(find.text(secondLeaf.title));
      await tester.pump(
        AppMotion.interestUnselected + AppMotion.interestFeedback,
      );
      expect(find.text('2 selecciones'), findsOneWidget);

      await tester.tap(find.text(leaf.title));
      await tester.pump(AppMotion.interestUnselected);
      expect(find.text('1 selección'), findsOneWidget);
      expect(result, isNull);

      await tester.tap(find.text('Continuar'));
      await tester.pump(AppMotion.graceful);
      expect(find.text('¿Te gustaría explorar algo más?'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('interest-explore-more')),
        findsOneWidget,
      );
      expect(find.text('Elegir otra área'), findsOneWidget);

      await tester.tap(find.text('Elegir otra área'));
      await tester.pump(AppMotion.graceful);
      expect(find.byKey(const ValueKey('interest-explore-more')), findsNothing);
      expect(find.text('¿Te gustaría explorar algo más?'), findsOneWidget);

      final software = InterestTree.roots[4];
      await tester.tap(find.text(software.title));
      await tester.pump(AppMotion.interestUnselected + AppMotion.screen);
      await tester.pump(
        (AppMotion.interestCardStagger * 4) + AppMotion.interestCardEntry,
      );
      await tester.tap(find.text(software.children.first.title));
      await tester.pump(
        AppMotion.interestUnselected + AppMotion.interestFeedback,
      );
      await tester.tap(find.text('Continuar'));
      await tester.pump(AppMotion.graceful);

      await tester.tap(find.text('Continuar').last);
      expect(result, [
        [cutting.title, secondLeaf.title],
        [software.title, software.children.first.title],
      ]);
    },
  );

  test('elige columnas automáticamente según la cantidad de opciones', () {
    expect(InterestGridMetrics.resolve(2).columns, 2);
    expect(InterestGridMetrics.resolve(4).columns, 2);
    expect(InterestGridMetrics.resolve(6).columns, 3);
    expect(InterestGridMetrics.resolve(9).columns, 3);
    expect(InterestGridMetrics.resolve(11).columns, 4);
  });
}
