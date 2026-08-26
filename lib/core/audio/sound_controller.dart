import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'sound_effect.dart';

abstract interface class SoundPlaybackEngine {
  Future<void> preload(List<String> assetPaths);

  Future<void> play(String assetPath, double volume);

  Future<void> stop();

  Future<void> dispose();
}

class SoundController extends ChangeNotifier {
  SoundController({SoundPlaybackEngine? engine})
    : _engine =
          engine ??
          (kIsWeb ? AudioplayersSoundEngine() : SilentSoundPlaybackEngine());

  static final SoundController instance = SoundController();

  final SoundPlaybackEngine _engine;

  Future<void>? _essentialPreloadFuture;
  Future<void>? _preloadFuture;
  bool _unlocked = false;
  bool _muted = false;
  bool _disposed = false;
  double _volume = 1;
  int _playRequest = 0;

  bool get isUnlocked => _unlocked;
  bool get isMuted => _muted;
  double get volume => _volume;

  Future<void> preload() {
    return _preloadFuture ??= _preloadAssets();
  }

  Future<void> preloadEssential() {
    return _essentialPreloadFuture ??= _preloadEssentialAssets();
  }

  Future<void> _preloadEssentialAssets() async {
    try {
      await _engine.preload([
        SoundEffect.tap.assetPath,
        SoundEffect.selection.assetPath,
      ]);
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudieron precargar los sonidos principales: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _preloadAssets() async {
    await preloadEssential();
    try {
      await _engine.preload(
        SoundEffect.values
            .where(
              (sound) =>
                  sound != SoundEffect.tap && sound != SoundEffect.selection,
            )
            .map((sound) => sound.assetPath)
            .toList(),
      );
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudieron precargar los sonidos: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> unlock({SoundEffect firstSound = SoundEffect.tap}) async {
    if (_disposed) return;

    if (!_unlocked) {
      _unlocked = true;
      notifyListeners();
      unawaited(preload());
    }
    await play(firstSound);
  }

  Future<void> play(SoundEffect sound, {double volumeScale = 1}) async {
    if (_disposed || !_unlocked || _muted) return;

    final request = ++_playRequest;
    try {
      await _engine.stop();
      if (_disposed || request != _playRequest || _muted) return;

      await _engine.play(
        sound.assetPath,
        (_volume * sound.relativeVolume * volumeScale)
            .clamp(0.0, 1.0)
            .toDouble(),
      );
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo reproducir ${sound.name}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> setMuted(bool value) async {
    if (_disposed || _muted == value) return;

    _muted = value;
    notifyListeners();
    if (value) {
      _playRequest++;
      await _engine.stop();
    }
  }

  Future<void> toggleMute() async {
    final willMute = !_muted;
    await setMuted(willMute);
    if (!willMute) {
      await play(SoundEffect.selection);
    }
  }

  void setVolume(double value) {
    if (_disposed) return;

    final nextVolume = value.clamp(0.0, 1.0).toDouble();
    if (_volume == nextVolume) return;
    _volume = nextVolume;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _playRequest++;
    unawaited(_engine.dispose());
    super.dispose();
  }
}

class SilentSoundPlaybackEngine implements SoundPlaybackEngine {
  @override
  Future<void> preload(List<String> assetPaths) async {}

  @override
  Future<void> play(String assetPath, double volume) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class AudioplayersSoundEngine implements SoundPlaybackEngine {
  AudioplayersSoundEngine() : _player = AudioPlayer(playerId: 'gpa-ui-sounds');

  final AudioPlayer _player;

  @override
  Future<void> preload(List<String> assetPaths) async {
    await AudioCache.instance.loadAll(assetPaths);
  }

  @override
  Future<void> play(String assetPath, double volume) async {
    await _player.play(
      AssetSource(assetPath),
      volume: volume,
      mode: PlayerMode.lowLatency,
    );
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

class SoundControllerScope extends InheritedNotifier<SoundController> {
  const SoundControllerScope({
    required SoundController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SoundController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SoundControllerScope>();
    assert(scope != null, 'No existe SoundControllerScope en este contexto.');
    return scope!.notifier!;
  }

  static SoundController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SoundControllerScope>()
        ?.notifier;
  }
}
