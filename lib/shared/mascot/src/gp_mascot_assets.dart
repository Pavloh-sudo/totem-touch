part of '../gp_mascot.dart';

abstract final class _GpAssetRig {
  static const _root = 'assets/mascot/gp';

  // Los valores corresponden a layers.json sobre un canvas de 1024 x 1024.
  static const headAlignment = Alignment(0, -0.0078125);
  static const armLeftAlignment = Alignment(0.251953125, 0.01953125);
  static const armRightAlignment = Alignment(-0.251953125, 0.01953125);

  static _GpArtworkLayers artworkFor(GpMascotContext mascotContext) {
    return _GpArtworkLayers(
      body: _asset('body.png'),
      head: _asset('head.png'),
      openEyes: _asset('eyes_open.png'),
      closedEyes: _asset('eyes_closed.png'),
      mouthNeutral: _asset('mouth_neutral.png'),
      mouthSmile: _asset('mouth_smile.png'),
      mouthThinking: _asset('mouth_thinking.png'),
      mouthError: _asset('mouth_error.png'),
      armLeftIdle: _asset('arm_left_idle.png'),
      armRightIdle: _asset('arm_right_idle.png'),
      armRightWave: _asset('arm_right_wave.png'),
      armRightGuide: _asset('arm_right_guide.png'),
      armLeftCelebrate: _asset('arm_left_celebrate.png'),
      armRightCelebrate: _asset('arm_right_celebrate.png'),
      shadow: _asset('shadow.png'),
      headAccessories: null,
      foreground: null,
      headAlignment: headAlignment,
      armLeftAlignment: armLeftAlignment,
      armRightAlignment: armRightAlignment,
    );
  }

  static Widget _asset(String fileName) {
    return Image.asset(
      '$_root/$fileName',
      key: ValueKey('gp-layer-$fileName'),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }
}
