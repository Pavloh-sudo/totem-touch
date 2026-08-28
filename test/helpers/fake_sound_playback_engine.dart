import 'package:kiosco_gpa/core/audio/sound_controller.dart';

class FakeSoundPlaybackEngine implements SoundPlaybackEngine {
  final List<List<String>> preloadCalls = [];
  final List<(String, double)> playCalls = [];
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> preload(List<String> assetPaths) async {
    preloadCalls.add(List.unmodifiable(assetPaths));
  }

  @override
  Future<void> play(String assetPath, double volume) async {
    playCalls.add((assetPath, volume));
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}
