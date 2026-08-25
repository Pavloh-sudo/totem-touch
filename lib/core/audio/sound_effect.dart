enum SoundEffect {
  tap('audio/ui_tap.wav', 0.225),
  selection('audio/ui_select.wav', 0.30),
  back('audio/ui_back.wav', 0.20),
  error('audio/ui_error.wav', 0.25),
  success('audio/ui_success.wav', 0.35),
  warning('audio/ui_warning.wav', 0.25);

  const SoundEffect(this.assetPath, this.relativeVolume);

  final String assetPath;
  final double relativeVolume;
}
