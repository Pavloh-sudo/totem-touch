import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/animations/app_motion.dart';
import 'package:totem_touch/shared/mascot/gp_mascot.dart';

void main() {
  Widget testApp(
    Widget child, {
    bool disableAnimations = false,
    bool tickerEnabled = true,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: TickerMode(
          enabled: tickerEnabled,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  GpMascot mascot({
    GpMascotState state = GpMascotState.idle,
    GpMascotContext mascotContext = GpMascotContext.defaultOutfit,
    double size = 240,
    bool playEntranceAnimation = true,
    bool enableIdleMotion = true,
    Widget? artwork,
    Key? key,
  }) {
    return GpMascot(
      key: key,
      state: state,
      mascotContext: mascotContext,
      size: size,
      playEntranceAnimation: playEntranceAnimation,
      enableIdleMotion: enableIdleMotion,
      artwork: artwork ?? const Text('GP'),
    );
  }

  Widget layeredArtwork() {
    return GpMascot.layeredArtworkForTesting(
      body: const Text('cuerpo'),
      head: const Text('cabeza'),
      openEyes: const Text('ojos abiertos'),
      closedEyes: const Text('ojos cerrados'),
      shadow: const ColoredBox(color: Colors.black12),
    );
  }

  testWidgets('carga las capas reales de GP cuando no recibe otro dibujo', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        const GpMascot(playEntranceAnimation: false, enableIdleMotion: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    const idleLayers = [
      'body.png',
      'head.png',
      'eyes_open.png',
      'mouth_neutral.png',
      'arm_left_idle.png',
      'arm_right_idle.png',
      'shadow.png',
    ];
    for (final layer in idleLayers) {
      expect(find.byKey(ValueKey('gp-layer-$layer')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('wave, guide y celebrate usan sus brazos independientes', (
    tester,
  ) async {
    var state = GpMascotState.idle;
    late StateSetter update;

    await tester.pumpWidget(
      testApp(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return GpMascot(
              state: state,
              playEntranceAnimation: false,
              enableIdleMotion: false,
            );
          },
        ),
      ),
    );

    update(() => state = GpMascotState.wave);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    expect(
      find.byKey(const ValueKey('gp-layer-arm_right_wave.png')),
      findsOneWidget,
    );

    update(() => state = GpMascotState.guide);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    expect(
      find.byKey(const ValueKey('gp-layer-arm_right_guide.png')),
      findsOneWidget,
    );

    update(() => state = GpMascotState.celebrate);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.byKey(const ValueKey('gp-layer-arm_left_celebrate.png')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('gp-layer-arm_right_celebrate.png')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('thinking y error cambian solamente la expresión de la cara', (
    tester,
  ) async {
    var state = GpMascotState.thinking;
    late StateSetter update;

    await tester.pumpWidget(
      testApp(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return GpMascot(
              state: state,
              playEntranceAnimation: false,
              enableIdleMotion: false,
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.byKey(const ValueKey('gp-layer-mouth_thinking.png')),
      findsOneWidget,
    );

    update(() => state = GpMascotState.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 325));
    expect(
      find.byKey(const ValueKey('gp-layer-mouth_error.png')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('conserva los valores predeterminados', (tester) async {
    await tester.pumpWidget(testApp(mascot()));

    final widget = tester.widget<GpMascot>(find.byType(GpMascot));
    expect(widget.state, GpMascotState.idle);
    expect(widget.mascotContext, GpMascotContext.defaultOutfit);
    expect(widget.size, 240);
    expect(widget.enableIdleMotion, isTrue);
    expect(widget.playEntranceAnimation, isTrue);
  });

  testWidgets('reacciona a cambios de estado y contexto sin desmontarse', (
    tester,
  ) async {
    var state = GpMascotState.idle;
    var mascotContext = GpMascotContext.defaultOutfit;
    late StateSetter update;

    await tester.pumpWidget(
      testApp(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return mascot(state: state, mascotContext: mascotContext);
          },
        ),
      ),
    );
    await tester.pump(AppMotion.emphasis);

    update(() {
      state = GpMascotState.celebrate;
      mascotContext = GpMascotContext.careers;
    });
    await tester.pump();

    final updated = tester.widget<GpMascot>(find.byType(GpMascot));
    expect(updated.state, GpMascotState.celebrate);
    expect(updated.mascotContext, GpMascotContext.careers);
    expect(find.byKey(const ValueKey('gp-context-careers')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1250));
    expect(tester.takeException(), isNull);

    update(() => state = GpMascotState.idle);
    await tester.pump();
    final backToIdle = tester.widget<GpMascot>(find.byType(GpMascot));
    expect(backToIdle.state, GpMascotState.idle);
    expect(backToIdle.mascotContext, GpMascotContext.careers);
  });

  testWidgets('un rebuild normal no repite la entrada', (tester) async {
    var rebuildCount = 0;
    late StateSetter update;

    await tester.pumpWidget(
      testApp(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Column(children: [Text('$rebuildCount'), mascot()]);
          },
        ),
      ),
    );
    await tester.pump(AppMotion.emphasis);

    Opacity entrance() {
      return tester.widget<Opacity>(
        find.byKey(const ValueKey('gp-entrance-opacity')),
      );
    }

    expect(entrance().opacity, 1);
    update(() => rebuildCount++);
    await tester.pump();
    expect(entrance().opacity, 1);
  });

  testWidgets('respeta la reducción de movimiento', (tester) async {
    await tester.pumpWidget(testApp(mascot(), disableAnimations: true));
    await tester.pump();

    final entrance = tester.widget<Opacity>(
      find.byKey(const ValueKey('gp-entrance-opacity')),
    );
    expect(entrance.opacity, 1);

    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mantiene el espacio reservado en distintos tamaños', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mascot(
              key: const ValueKey('small-gp'),
              size: 80,
              playEntranceAnimation: false,
              enableIdleMotion: false,
            ),
            mascot(
              key: const ValueKey('large-gp'),
              size: 320,
              playEntranceAnimation: false,
              enableIdleMotion: false,
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('small-gp'))),
      const Size.square(80),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('large-gp'))),
      const Size.square(320),
    );
  });

  testWidgets('combina estados y contextos de forma independiente', (
    tester,
  ) async {
    const combinations = [
      (GpMascotState.idle, GpMascotContext.defaultOutfit),
      (GpMascotState.guide, GpMascotContext.robotics),
      (GpMascotState.thinking, GpMascotContext.software),
      (GpMascotState.celebrate, GpMascotContext.careers),
      (GpMascotState.error, GpMascotContext.manufacturing),
      (GpMascotState.wave, GpMascotContext.defaultOutfit),
    ];

    for (final combination in combinations) {
      await tester.pumpWidget(
        testApp(
          mascot(
            state: combination.$1,
            mascotContext: combination.$2,
            playEntranceAnimation: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1300));

      final current = tester.widget<GpMascot>(find.byType(GpMascot));
      expect(current.state, combination.$1);
      expect(current.mascotContext, combination.$2);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('limpia controladores y timers al desmontarse', (tester) async {
    for (var index = 0; index < 3; index++) {
      await tester.pumpWidget(testApp(mascot(artwork: layeredArtwork())));
      await tester.pump(const Duration(seconds: 13));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 13));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('el idle conserva su layout durante 60 segundos', (tester) async {
    await tester.pumpWidget(testApp(mascot(artwork: layeredArtwork())));
    await tester.pump(AppMotion.emphasis);
    final initialRect = tester.getRect(find.byType(GpMascot));

    for (var second = 0; second < 60; second++) {
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getRect(find.byType(GpMascot)), initialRect);
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 13));
    expect(tester.takeException(), isNull);
  });

  testWidgets('TickerMode detiene el trabajo fuera de foco', (tester) async {
    var enabled = false;
    late StateSetter update;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return testApp(
            mascot(artwork: layeredArtwork()),
            tickerEnabled: enabled,
          );
        },
      ),
    );
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);

    update(() => enabled = true);
    await tester.pump();
    await tester.pump(AppMotion.emphasis);
    expect(tester.takeException(), isNull);
  });
}
