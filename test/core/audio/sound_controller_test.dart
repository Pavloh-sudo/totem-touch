import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/audio/sound_controller.dart';
import 'package:totem_touch/core/audio/sound_effect.dart';

import '../../helpers/fake_sound_playback_engine.dart';

void main() {
  test(
    'precarga primero los sonidos principales y después los demás',
    () async {
      final engine = FakeSoundPlaybackEngine();
      final controller = SoundController(engine: engine);
      addTearDown(controller.dispose);

      await controller.preloadEssential();
      await controller.preloadEssential();
      await controller.preload();
      await controller.preload();

      expect(engine.preloadCalls, hasLength(2));
      expect(
        engine.preloadCalls.expand((paths) => paths),
        SoundEffect.values.map((sound) => sound.assetPath),
      );
    },
  );

  test('el primer gesto desbloquea el audio y reproduce el tap', () async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);

    await controller.unlock();

    expect(controller.isUnlocked, isTrue);
    expect(engine.stopCalls, 1);
    expect(engine.playCalls, [('audio/ui_tap.wav', 0.225)]);
  });

  test('aplica volumen relativo, mute e interrupción', () async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);

    await controller.unlock();
    engine.playCalls.clear();
    engine.stopCalls = 0;

    controller.setVolume(0.5);
    await controller.play(SoundEffect.success);
    expect(engine.stopCalls, 1);
    expect(engine.playCalls.single.$1, 'audio/ui_success.wav');
    expect(engine.playCalls.single.$2, closeTo(0.175, 0.0001));

    await controller.setMuted(true);
    await controller.play(SoundEffect.error);
    expect(controller.isMuted, isTrue);
    expect(engine.playCalls, hasLength(1));
  });

  test('permite bajar el volumen de una interacción puntual', () async {
    final engine = FakeSoundPlaybackEngine();
    final controller = SoundController(engine: engine);
    addTearDown(controller.dispose);
    await controller.unlock();
    engine.playCalls.clear();

    await controller.play(SoundEffect.selection, volumeScale: 2 / 3);

    expect(engine.playCalls.single.$1, 'audio/ui_select.wav');
    expect(engine.playCalls.single.$2, closeTo(0.20, 0.0001));
  });
}
