import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/animations/app_motion.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/session/registration_session_controller.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/data/local/memory_interest_submission_repository.dart';
import 'package:totem_touch/data/models/registration_session.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';
import 'package:totem_touch/features/interests/domain/interest_tree.dart';
import 'package:totem_touch/features/interests/presentation/interests_screen.dart';
import 'package:totem_touch/features/interests/presentation/widgets/interest_option_card.dart';
import 'package:totem_touch/features/interests/presentation/widgets/interest_options_grid.dart';
import 'package:totem_touch/shared/feedback/gpa_progress_indicator.dart';
import 'package:totem_touch/shared/mascot/gp_mascot.dart';

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
    required MemoryInterestSubmissionRepository repository,
    required Future<void> Function(RegistrationSession session) onCompleted,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    final controller = SoundController(engine: FakeSoundPlaybackEngine());
    addTearDown(controller.dispose);
    final sessionController = RegistrationSessionController(
      idGenerator: () => 'session-prueba',
    );
    addTearDown(sessionController.dispose);
    sessionController.begin();
    sessionController.setRegistration(registration);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: InterestsScreen(
          sessionController: sessionController,
          repository: repository,
          onBack: () {},
          onCompleted: onCompleted,
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
    await pumpScreen(
      tester,
      repository: MemoryInterestSubmissionRepository(),
      onCompleted: (_) async {},
    );
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
    await pumpScreen(
      tester,
      repository: MemoryInterestSubmissionRepository(),
      onCompleted: (_) async {},
    );
    await tester.pump(
      (AppMotion.interestCardStagger * 5) + AppMotion.interestCardEntry,
    );

    final robotics = InterestTree.roots.first;
    await tester.tap(find.text(robotics.title));
    await tester.pump(AppMotion.interestUnselected + AppMotion.standard);
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
    'permite varias opciones, pregunta si continúa y guarda una sola vez',
    (tester) async {
      final repository = MemoryInterestSubmissionRepository();
      RegistrationSession? completed;
      await pumpScreen(
        tester,
        repository: repository,
        onCompleted: (submission) async => completed = submission,
      );
      await tester.pump(
        (AppMotion.interestCardStagger * 5) + AppMotion.interestCardEntry,
      );

      final cutting = InterestTree.roots[1];
      await tester.tap(find.text(cutting.title));
      await tester.pump(AppMotion.interestUnselected + AppMotion.standard);
      await tester.pump(
        (AppMotion.interestCardStagger * 3) + AppMotion.interestCardEntry,
      );
      final leaf = cutting.children.first;
      final secondLeaf = cutting.children[1];

      await tester.tap(find.text(leaf.title));
      await tester.tap(find.text(leaf.title));
      await tester.pump(AppMotion.interestUnselected + AppMotion.standard);

      expect(repository.submissions, isEmpty);
      expect(find.text('Interés agregado'), findsOneWidget);
      expect(
        find.text('¿Quieres seleccionar algo más o terminamos?'),
        findsOneWidget,
      );
      expect(find.text('Elegir otra'), findsOneWidget);
      expect(completed, isNull);

      await tester.tap(find.text('Elegir otra'));
      await tester.pump(AppMotion.standard);
      expect(
        find.byKey(const ValueKey('interest-selection-count')),
        findsOneWidget,
      );
      await tester.tap(find.text(secondLeaf.title));
      await tester.pump(AppMotion.interestUnselected + AppMotion.standard);
      expect(find.textContaining('Ya llevas 2 selecciones'), findsOneWidget);

      await tester.tap(find.text('Terminar').last);
      await tester.pump(AppMotion.interestSaving);

      expect(completed, isNotNull);
      expect(completed!.interestPath, [cutting.title, leaf.title]);
      expect(completed!.interestPaths, [
        [cutting.title, leaf.title],
        [cutting.title, secondLeaf.title],
      ]);
      expect(completed!.finalInterest, secondLeaf.title);
      expect(repository.submissions, hasLength(1));
    },
  );

  test('elige columnas automáticamente según la cantidad de opciones', () {
    expect(InterestGridMetrics.resolve(2).columns, 2);
    expect(InterestGridMetrics.resolve(4).columns, 2);
    expect(InterestGridMetrics.resolve(6).columns, 3);
    expect(InterestGridMetrics.resolve(9).columns, 3);
    expect(InterestGridMetrics.resolve(11).columns, 4);
  });

  testWidgets('si falla el guardado permite volver a intentarlo', (
    tester,
  ) async {
    final repository = _FailingRepository();
    RegistrationSession? completed;
    await pumpScreen(
      tester,
      repository: repository,
      onCompleted: (submission) async => completed = submission,
    );
    await tester.pump(
      (AppMotion.interestCardStagger * 5) + AppMotion.interestCardEntry,
    );

    final cutting = InterestTree.roots[1];
    await tester.tap(find.text(cutting.title));
    await tester.pump(AppMotion.interestUnselected + AppMotion.standard);
    await tester.pump(
      (AppMotion.interestCardStagger * 3) + AppMotion.interestCardEntry,
    );
    await tester.tap(find.text(cutting.children.first.title));
    await tester.pump(AppMotion.interestUnselected + AppMotion.standard);
    await tester.tap(find.text('Terminar'));
    await tester.pump(AppMotion.interestSaving);

    expect(completed, isNull);
    expect(repository.submissions, isEmpty);
    expect(
      find.byKey(const ValueKey('interest-continue-or-finish')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<GpMascot>(
            find.byKey(const ValueKey('interests-header-mascot')),
          )
          .state,
      GpMascotState.error,
    );
  });
}

class _FailingRepository extends MemoryInterestSubmissionRepository {
  @override
  Future<void> save(RegistrationSession session) async {
    throw StateError('Sin espacio disponible');
  }
}
