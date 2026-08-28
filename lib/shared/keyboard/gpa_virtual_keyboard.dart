import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/animations/app_motion.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/audio/sound_effect.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_surfaces.dart';
import '../../core/theme/app_typography.dart';

enum GpaKeyboardLayout { text, email, numeric }

class GpaVirtualKeyboard extends StatelessWidget {
  const GpaVirtualKeyboard({
    required this.visible,
    required this.layout,
    required this.onText,
    required this.onBackspace,
    required this.onDone,
    super.key,
  });

  final bool visible;
  final GpaKeyboardLayout layout;
  final ValueChanged<String> onText;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  static const _keyboardHeight = 268.0;

  @override
  Widget build(BuildContext context) {
    final duration = visible ? AppMotion.keyboardShow : AppMotion.keyboardHide;
    final soundController = SoundControllerScope.maybeOf(context);

    void playTap() {
      if (soundController != null) {
        unawaited(soundController.play(SoundEffect.tap, volumeScale: 0.6));
      }
    }

    return IgnorePointer(
      ignoring: !visible,
      child: ClipRect(
        child: AnimatedAlign(
          key: const ValueKey('gpa-virtual-keyboard-space'),
          duration: duration,
          curve: AppMotion.standardCurve,
          alignment: Alignment.topCenter,
          heightFactor: visible ? 1 : 0,
          child: AnimatedSlide(
            duration: duration,
            curve: AppMotion.standardCurve,
            offset: visible ? Offset.zero : const Offset(0, 1),
            child: SizedBox(
              height: _keyboardHeight,
              child: _KeyboardSurface(
                layout: layout,
                onText: (value) {
                  playTap();
                  onText(value);
                },
                onBackspace: () {
                  playTap();
                  onBackspace();
                },
                onDone: () {
                  playTap();
                  onDone();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyboardSurface extends StatefulWidget {
  const _KeyboardSurface({
    required this.layout,
    required this.onText,
    required this.onBackspace,
    required this.onDone,
  });

  final GpaKeyboardLayout layout;
  final ValueChanged<String> onText;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  @override
  State<_KeyboardSurface> createState() => _KeyboardSurfaceState();
}

class _KeyboardSurfaceState extends State<_KeyboardSurface> {
  _EmailKeyboardPage _emailPage = _EmailKeyboardPage.letters;

  @override
  void didUpdateWidget(covariant _KeyboardSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layout != widget.layout &&
        _emailPage != _EmailKeyboardPage.letters) {
      _emailPage = _EmailKeyboardPage.letters;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rowsFor(widget.layout);
    final keyboard = Container(
      height: 268,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSurfaces.radius),
        ),
        border: Border(
          top: BorderSide(color: AppColors.steel.withValues(alpha: 0.36)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.carbon.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
            Expanded(
              child: Row(
                children: [
                  for (
                    var keyIndex = 0;
                    keyIndex < rows[rowIndex].length;
                    keyIndex++
                  ) ...[
                    Expanded(
                      flex: rows[rowIndex][keyIndex].flex,
                      child: _buildKey(rows[rowIndex][keyIndex]),
                    ),
                    if (keyIndex < rows[rowIndex].length - 1)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            if (rowIndex < rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );

    if (widget.layout != GpaKeyboardLayout.numeric) return keyboard;
    return Center(child: SizedBox(width: 440, child: keyboard));
  }

  Widget _buildKey(_KeyboardKeySpec key) {
    return switch (key.action) {
      _KeyboardAction.text => _KeyboardKey(
        label: key.label,
        compact: key.compact,
        shortcut: key.shortcut,
        onTap: () => widget.onText(key.value!),
      ),
      _KeyboardAction.backspace => _BackspaceKey(
        onBackspace: widget.onBackspace,
      ),
      _KeyboardAction.done => _KeyboardKey(
        icon: Icons.check_rounded,
        semanticLabel: 'Listo',
        accent: true,
        onTap: widget.onDone,
      ),
      _KeyboardAction.numbers => _KeyboardKey(
        label: '123',
        semanticLabel: 'Mostrar números',
        onTap: () => setState(() => _emailPage = _EmailKeyboardPage.numbers),
      ),
      _KeyboardAction.letters => _KeyboardKey(
        label: 'ABC',
        semanticLabel: 'Mostrar letras',
        onTap: () => setState(() => _emailPage = _EmailKeyboardPage.letters),
      ),
    };
  }

  List<List<_KeyboardKeySpec>> _rowsFor(GpaKeyboardLayout layout) {
    return switch (layout) {
      GpaKeyboardLayout.text => [
        _letters('qwertyuiop'),
        _letters('asdfghjklñ'),
        [..._letters('zxcvbnm'), const _KeyboardKeySpec.backspace(flex: 2)],
        const [
          _KeyboardKeySpec.text('Espacio', ' ', flex: 6),
          _KeyboardKeySpec.text(',', ','),
          _KeyboardKeySpec.text('.', '.'),
          _KeyboardKeySpec.done(flex: 2),
        ],
      ],
      GpaKeyboardLayout.email => _emailRows(),
      GpaKeyboardLayout.numeric => const [
        [
          _KeyboardKeySpec.text('1', '1'),
          _KeyboardKeySpec.text('2', '2'),
          _KeyboardKeySpec.text('3', '3'),
        ],
        [
          _KeyboardKeySpec.text('4', '4'),
          _KeyboardKeySpec.text('5', '5'),
          _KeyboardKeySpec.text('6', '6'),
        ],
        [
          _KeyboardKeySpec.text('7', '7'),
          _KeyboardKeySpec.text('8', '8'),
          _KeyboardKeySpec.text('9', '9'),
        ],
        [
          _KeyboardKeySpec.backspace(),
          _KeyboardKeySpec.text('0', '0'),
          _KeyboardKeySpec.done(),
        ],
      ],
    };
  }

  List<List<_KeyboardKeySpec>> _emailRows() {
    return switch (_emailPage) {
      _EmailKeyboardPage.letters => [
        _letters('qwertyuiop'),
        _letters('asdfghjkl'),
        [..._letters('zxcvbnm'), const _KeyboardKeySpec.backspace(flex: 2)],
        const [
          _KeyboardKeySpec.numbers(),
          _KeyboardKeySpec.text('@', '@'),
          _KeyboardKeySpec.text('.', '.'),
          _KeyboardKeySpec.text('_', '_'),
          _KeyboardKeySpec.text('-', '-'),
          _KeyboardKeySpec.text(
            '@gmail.com',
            '@gmail.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '@hotmail.com',
            '@hotmail.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '@outlook.com',
            '@outlook.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '@yahoo.com',
            '@yahoo.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '.com',
            '.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.done(),
        ],
      ],
      _EmailKeyboardPage.numbers => const [
        [
          _KeyboardKeySpec.text('1', '1'),
          _KeyboardKeySpec.text('2', '2'),
          _KeyboardKeySpec.text('3', '3'),
          _KeyboardKeySpec.text('4', '4'),
          _KeyboardKeySpec.text('5', '5'),
        ],
        [
          _KeyboardKeySpec.text('6', '6'),
          _KeyboardKeySpec.text('7', '7'),
          _KeyboardKeySpec.text('8', '8'),
          _KeyboardKeySpec.text('9', '9'),
          _KeyboardKeySpec.text('0', '0'),
        ],
        [
          _KeyboardKeySpec.text('@', '@'),
          _KeyboardKeySpec.text('.', '.'),
          _KeyboardKeySpec.text('_', '_'),
          _KeyboardKeySpec.text('-', '-'),
          _KeyboardKeySpec.backspace(),
        ],
        [
          _KeyboardKeySpec.letters(),
          _KeyboardKeySpec.text(
            '@gmail.com',
            '@gmail.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '@hotmail.com',
            '@hotmail.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '@outlook.com',
            '@outlook.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '@yahoo.com',
            '@yahoo.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.text(
            '.com',
            '.com',
            flex: 2,
            compact: true,
            shortcut: true,
          ),
          _KeyboardKeySpec.backspace(),
          _KeyboardKeySpec.done(),
        ],
      ],
    };
  }

  List<_KeyboardKeySpec> _letters(String letters) {
    return letters
        .split('')
        .map((letter) => _KeyboardKeySpec.text(letter.toUpperCase(), letter))
        .toList();
  }
}

enum _EmailKeyboardPage { letters, numbers }

enum _KeyboardAction { text, backspace, done, numbers, letters }

class _KeyboardKeySpec {
  const _KeyboardKeySpec.text(
    this.label,
    this.value, {
    this.flex = 1,
    this.compact = false,
    this.shortcut = false,
  }) : action = _KeyboardAction.text;

  const _KeyboardKeySpec.backspace({this.flex = 1})
    : label = '',
      value = null,
      compact = false,
      shortcut = false,
      action = _KeyboardAction.backspace;

  const _KeyboardKeySpec.done({this.flex = 1})
    : label = '',
      value = null,
      compact = false,
      shortcut = false,
      action = _KeyboardAction.done;

  const _KeyboardKeySpec.numbers()
    : label = '123',
      value = null,
      flex = 1,
      compact = false,
      shortcut = false,
      action = _KeyboardAction.numbers;

  const _KeyboardKeySpec.letters()
    : label = 'ABC',
      value = null,
      flex = 1,
      compact = false,
      shortcut = false,
      action = _KeyboardAction.letters;

  final String label;
  final String? value;
  final int flex;
  final bool compact;
  final bool shortcut;
  final _KeyboardAction action;
}

class _KeyboardKey extends StatefulWidget {
  const _KeyboardKey({
    required this.onTap,
    this.label,
    this.icon,
    this.semanticLabel,
    this.accent = false,
    this.compact = false,
    this.shortcut = false,
  });

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final bool accent;
  final bool compact;
  final bool shortcut;
  final VoidCallback onTap;

  @override
  State<_KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<_KeyboardKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          duration: _pressed ? AppMotion.touchDown : AppMotion.touchUp,
          curve: AppMotion.standardCurve,
          scale: _pressed ? 0.965 : 1,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.accent
                  ? AppColors.gpaCrimson
                  : widget.shortcut
                  ? AppColors.techCyan.withValues(alpha: 0.08)
                  : AppColors.porcelain,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.accent
                    ? AppColors.gpaCrimson
                    : widget.shortcut
                    ? AppColors.techCyan.withValues(alpha: 0.28)
                    : AppColors.steel.withValues(alpha: 0.38),
              ),
            ),
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: widget.accent
                        ? AppColors.pureWhite
                        : AppColors.carbon,
                    size: 26,
                  )
                : Text(
                    widget.label!,
                    style: AppTypography.button.copyWith(
                      color: widget.accent
                          ? AppColors.pureWhite
                          : widget.shortcut
                          ? AppColors.graphite
                          : AppColors.carbon,
                      fontSize: widget.compact ? 13 : 18,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatefulWidget {
  const _BackspaceKey({required this.onBackspace});

  final VoidCallback onBackspace;

  @override
  State<_BackspaceKey> createState() => _BackspaceKeyState();
}

class _BackspaceKeyState extends State<_BackspaceKey> {
  Timer? _holdTimer;
  Timer? _repeatTimer;
  bool _repeating = false;

  void _start(TapDownDetails details) {
    _cancel();
    _holdTimer = Timer(AppMotion.keyboardBackspaceHold, () {
      _repeating = true;
      widget.onBackspace();
      _repeatTimer = Timer.periodic(
        AppMotion.keyboardBackspaceRepeat,
        (_) => widget.onBackspace(),
      );
    });
  }

  void _finish(TapUpDetails details) {
    if (!_repeating) widget.onBackspace();
    _cancel();
  }

  void _cancel() {
    _holdTimer?.cancel();
    _repeatTimer?.cancel();
    _holdTimer = null;
    _repeatTimer = null;
    _repeating = false;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Borrar',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _start,
        onTapUp: _finish,
        onTapCancel: _cancel,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.porcelain,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.steel.withValues(alpha: 0.38)),
          ),
          child: const Icon(
            Icons.backspace_outlined,
            color: AppColors.carbon,
            size: 25,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
