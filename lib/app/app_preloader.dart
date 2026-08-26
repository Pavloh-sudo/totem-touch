import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/animations/app_motion.dart';
import '../core/audio/sound_controller.dart';
import '../core/configuration/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../data/repositories/interest_submission_repository.dart';

class AppPreloader extends StatefulWidget {
  const AppPreloader({
    required this.repository,
    required this.child,
    super.key,
  });

  final InterestSubmissionRepository repository;
  final Widget child;

  @override
  State<AppPreloader> createState() => _AppPreloaderState();
}

class _AppPreloaderState extends State<AppPreloader> {
  bool _started = false;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    unawaited(_preload());
  }

  Future<void> _preload() async {
    await Future.wait([
      widget.repository.initialize(),
      if (kIsWeb) SoundController.instance.preloadEssential(),
      ...AssetPaths.initialImages.map(_cacheImage),
    ]);
    if (!mounted) return;
    setState(() => _ready = true);
    if (kIsWeb) unawaited(SoundController.instance.preload());
    unawaited(_preloadDeferredImages());
  }

  Future<void> _preloadDeferredImages() async {
    for (final path in AssetPaths.deferredImages) {
      if (!mounted) return;
      await _cacheImage(path);
    }
  }

  Future<void> _cacheImage(String path) async {
    try {
      final asset = AssetImage(path);
      final provider = path.contains('/mascot/')
          ? ResizeImage.resizeIfNeeded(512, null, asset)
          : asset;
      await precacheImage(provider, context);
    } on Object catch (error, stackTrace) {
      debugPrint('No se pudo precargar $path: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.emphasis,
      child: _ready
          ? widget.child
          : const _TechnicalSplash(key: ValueKey('technical-splash')),
    );
  }
}

class _TechnicalSplash extends StatelessWidget {
  const _TechnicalSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.porcelain,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.gpaLogo,
              width: 118,
              height: 118,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.gpaCrimson,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
