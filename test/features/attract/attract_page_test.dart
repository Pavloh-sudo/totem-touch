import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/app/kiosk_shell.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/configuration/kiosk_configuration.dart';
import 'package:totem_touch/core/theme/app_theme.dart';
import 'package:totem_touch/features/attract/presentation/attract_page.dart';
import 'package:totem_touch/shared/mascot/gp_mascot.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  testWidgets('GP entra, saluda y después vuelve a idle', (tester) async {
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
          headerHeight: KioskConfiguration.attractHeaderHeight,
          logoSize: KioskConfiguration.attractLogoSize,
          child: const AttractPage(onStart: _completedStart),
        ),
      ),
    );

    GpMascot mascot() => tester.widget<GpMascot>(find.byType(GpMascot));

    expect(mascot().state, GpMascotState.idle);
    await tester.pump(const Duration(milliseconds: 420));
    expect(mascot().state, GpMascotState.wave);
    await tester.pump(const Duration(milliseconds: 920));
    expect(mascot().state, GpMascotState.idle);
    await tester.pump(const Duration(seconds: 15));
    expect(mascot().state, GpMascotState.guide);
  });

  testWidgets('el CTA usa selección y GP reacciona', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    final navigation = Completer<void>();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.kiosk,
        home: KioskShell(
          soundController: controller,
          inactivityTimeout: null,
          headerHeight: KioskConfiguration.attractHeaderHeight,
          logoSize: KioskConfiguration.attractLogoSize,
          child: AttractPage(onStart: () => navigation.future),
        ),
      ),
    );
    await tester.tap(find.text('Quiero conocer más'));
    await tester.pump();

    expect(controller.isUnlocked, isTrue);
    expect(engine.playCalls.single.$1, 'audio/ui_select.wav');
    expect(
      tester.widget<GpMascot>(find.byType(GpMascot)).state,
      GpMascotState.wave,
    );
    navigation.complete();
    await tester.pump();
  });
}

Future<void> _completedStart() async {}
