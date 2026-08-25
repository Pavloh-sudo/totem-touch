import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/animations/app_motion.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/audio/sound_effect.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum GpaTouchFieldState { idle, focus, filled, valid, error, disabled }

class GpaTouchField extends StatefulWidget {
  const GpaTouchField({
    required this.controller,
    required this.label,
    required this.onTap,
    this.focusNode,
    this.hint,
    this.errorText,
    this.isValid = false,
    this.enabled = true,
    this.obscureText = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final String? errorText;
  final bool isValid;
  final bool enabled;
  final bool obscureText;
  final VoidCallback onTap;

  @override
  State<GpaTouchField> createState() => _GpaTouchFieldState();
}

class _GpaTouchFieldState extends State<GpaTouchField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _ownedFocusNode;
  late final AnimationController _errorController;
  late final Animation<double> _errorOffset;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode;

  bool get _hasFocus => _focusNode.hasFocus;

  GpaTouchFieldState get _visualState {
    if (!widget.enabled) return GpaTouchFieldState.disabled;
    if (widget.errorText != null) return GpaTouchFieldState.error;
    if (_hasFocus) return GpaTouchFieldState.focus;
    if (widget.isValid) return GpaTouchFieldState.valid;
    if (widget.controller.text.isNotEmpty) return GpaTouchFieldState.filled;
    return GpaTouchFieldState.idle;
  }

  @override
  void initState() {
    super.initState();
    _ownedFocusNode = FocusNode();
    _focusNode.addListener(_refresh);
    widget.controller.addListener(_refresh);
    _errorController = AnimationController(
      vsync: this,
      duration: AppMotion.fieldError,
    );
    _errorOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 18),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 4, end: -3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -3, end: 3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 3, end: 0), weight: 22),
    ]).animate(CurvedAnimation(parent: _errorController, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(covariant GpaTouchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode).removeListener(_refresh);
      _focusNode.addListener(_refresh);
    }
    if (widget.errorText != null && oldWidget.errorText != widget.errorText) {
      _errorController.forward(from: 0);
      final soundController = SoundControllerScope.maybeOf(context);
      if (soundController != null) {
        unawaited(soundController.play(SoundEffect.error));
      }
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _activate() {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final state = _visualState;
    final focused = _hasFocus;
    final error = state == GpaTouchFieldState.error;
    final valid = state == GpaTouchFieldState.valid;
    final borderColor = focused || error
        ? AppColors.gpaCrimson
        : AppColors.steel.withValues(alpha: 0.62);
    final labelColor = focused || error
        ? AppColors.gpaCrimson
        : AppColors.graphite;

    return Semantics(
      textField: true,
      label: widget.label,
      enabled: widget.enabled,
      child: AnimatedBuilder(
        animation: _errorOffset,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_errorOffset.value, 0),
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _activate,
              child: AnimatedContainer(
                duration: AppMotion.fieldFocus,
                curve: AppMotion.standardCurve,
                height: 76,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? AppColors.pureWhite
                      : AppColors.steel.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                    width: focused || error ? 2 : 1.2,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 10,
                      right: 56,
                      child: AnimatedSlide(
                        duration: AppMotion.fieldFocus,
                        curve: AppMotion.standardCurve,
                        offset: Offset(0, focused ? -4 / 20 : 0),
                        child: AnimatedDefaultTextStyle(
                          duration: AppMotion.fieldFocus,
                          curve: AppMotion.standardCurve,
                          style: AppTypography.auxiliary.copyWith(
                            color: labelColor,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Text(widget.label),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 50,
                      top: 30,
                      bottom: 4,
                      child: IgnorePointer(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          readOnly: true,
                          showCursor: focused,
                          obscureText: widget.obscureText,
                          style: AppTypography.field,
                          decoration: InputDecoration(
                            hintText: widget.hint,
                            hintStyle: AppTypography.field.copyWith(
                              color: AppColors.steel,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      top: 26,
                      child: AnimatedScale(
                        duration: AppMotion.fieldValidCheck,
                        curve: Curves.easeOutBack,
                        scale: valid ? 1 : 0.6,
                        child: AnimatedOpacity(
                          duration: AppMotion.fieldValidCheck,
                          opacity: valid ? 1 : 0,
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.successGreen,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 22,
              child: Padding(
                padding: const EdgeInsets.only(left: 14, top: 3),
                child: AnimatedOpacity(
                  duration: AppMotion.fast,
                  opacity: error ? 1 : 0,
                  child: Text(
                    widget.errorText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.auxiliary.copyWith(
                      color: AppColors.gpaCrimson,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_refresh);
    widget.controller.removeListener(_refresh);
    _ownedFocusNode.dispose();
    _errorController.dispose();
    super.dispose();
  }
}
