import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/kiosk_shell.dart';
import '../../../core/animations/app_motion.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/session/registration_session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/registration_session.dart';
import '../../../data/repositories/interest_submission_repository.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../../../shared/feedback/gpa_progress_indicator.dart';
import '../../../shared/keyboard/gpa_virtual_keyboard.dart';
import '../../../shared/mascot/gp_mascot.dart';

class AdditionalMessageScreen extends StatefulWidget {
  const AdditionalMessageScreen({
    required this.interestPaths,
    required this.sessionController,
    required this.repository,
    required this.onBack,
    required this.onCompleted,
    required this.onSessionExpired,
    super.key,
  });

  final List<List<String>> interestPaths;
  final RegistrationSessionController sessionController;
  final InterestSubmissionRepository repository;
  final VoidCallback onBack;
  final Future<void> Function(RegistrationSession session) onCompleted;
  final VoidCallback onSessionExpired;

  @override
  State<AdditionalMessageScreen> createState() =>
      _AdditionalMessageScreenState();
}

class _AdditionalMessageScreenState extends State<AdditionalMessageScreen> {
  static const _maximumLength = 300;

  final _messageController = TextEditingController();
  final _messageFocus = FocusNode();
  bool _keyboardVisible = false;
  bool _saving = false;
  bool _saveFailed = false;

  void _showKeyboard() {
    if (_saving || _keyboardVisible) return;
    setState(() {
      _keyboardVisible = true;
      _saveFailed = false;
    });
    _messageFocus.requestFocus();
  }

  void _dismissKeyboard() {
    if (!_keyboardVisible) return;
    setState(() => _keyboardVisible = false);
    _messageFocus.unfocus();
  }

  void _write(String value) {
    if (_messageController.text.length + value.length > _maximumLength) return;
    var nextValue = value;
    if (value.length == 1 &&
        (value == value.toLowerCase()) &&
        (_messageController.text.isEmpty ||
            _messageController.text.endsWith('. '))) {
      nextValue = value.toUpperCase();
    }
    setState(() {
      _messageController.text += nextValue;
      _messageController.selection = TextSelection.collapsed(
        offset: _messageController.text.length,
      );
      _saveFailed = false;
    });
  }

  void _backspace() {
    if (_messageController.text.isEmpty) return;
    setState(() {
      _messageController.text = _messageController.text.substring(
        0,
        _messageController.text.length - 1,
      );
      _messageController.selection = TextSelection.collapsed(
        offset: _messageController.text.length,
      );
      _saveFailed = false;
    });
  }

  void _finish({required bool omitMessage}) {
    if (_saving) return;
    final keyboardWasVisible = _keyboardVisible;
    _dismissKeyboard();
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    unawaited(
      _save(omitMessage: omitMessage, waitForKeyboard: keyboardWasVisible),
    );
  }

  Future<void> _save({
    required bool omitMessage,
    required bool waitForKeyboard,
  }) async {
    try {
      final session = widget.sessionController.completeAll(
        widget.interestPaths,
        additionalMessage: omitMessage ? '' : _messageController.text,
      );
      final transitionDelay =
          AppMotion.interestSaving +
          (waitForKeyboard ? AppMotion.keyboardHide : Duration.zero);
      await Future.wait([
        widget.repository.save(session),
        Future<void>.delayed(transitionDelay),
      ]);
      if (!mounted) return;
      await widget.onCompleted(session);
    } catch (_) {
      if (!mounted) return;
      final sound = SoundControllerScope.maybeOf(context);
      if (sound != null) unawaited(sound.play(SoundEffect.error));
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KioskShell(
      progressStage: KioskProgressStage.detail,
      onSessionExpired: widget.onSessionExpired,
      headerCompanion: const GpMascot(
        key: ValueKey('additional-message-mascot'),
        size: 76,
        state: GpMascotState.thinking,
        playEntranceAnimation: false,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '¿Quieres compartirnos algo más?',
                  style: AppTypography.screenTitle,
                ),
                const SizedBox(height: 5),
                Text(
                  'Si hay algo más que debamos saber, puedes escribirlo aquí. '
                  'Este paso es opcional.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: AppMotion.keyboardShow,
                  curve: AppMotion.standardCurve,
                  height: _keyboardVisible ? 132 : 190,
                  child: _AdditionalMessageField(
                    controller: _messageController,
                    focusNode: _messageFocus,
                    maximumLength: _maximumLength,
                    onTap: _showKeyboard,
                  ),
                ),
                AnimatedSize(
                  duration: AppMotion.fast,
                  child: _saveFailed
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.gpaCrimson,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No pudimos guardar el registro. Inténtalo nuevamente.',
                                style: AppTypography.auxiliary.copyWith(
                                  color: AppColors.gpaCrimson,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const Spacer(),
                Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: GpaSecondaryButton(
                        label: 'Volver',
                        icon: Icons.arrow_back_rounded,
                        height: 64,
                        sound: SoundEffect.back,
                        onPressed: _saving ? null : widget.onBack,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 170,
                      child: GpaSecondaryButton(
                        label: 'Omitir',
                        height: 64,
                        onPressed: _saving
                            ? null
                            : () => _finish(omitMessage: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 220,
                      child: GpaPrimaryButton(
                        label: _saving ? 'Guardando' : 'Finalizar',
                        icon: Icons.check_rounded,
                        trailingIcon: true,
                        height: 64,
                        state: _saving
                            ? GpaButtonState.loading
                            : GpaButtonState.normal,
                        sound: SoundEffect.selection,
                        onPressed: _saving
                            ? null
                            : () => _finish(omitMessage: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GpaVirtualKeyboard(
            visible: _keyboardVisible,
            layout: GpaKeyboardLayout.text,
            onText: _write,
            onBackspace: _backspace,
            onDone: _dismissKeyboard,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }
}

class _AdditionalMessageField extends StatelessWidget {
  const _AdditionalMessageField({
    required this.controller,
    required this.focusNode,
    required this.maximumLength,
    required this.onTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int maximumLength;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    return Semantics(
      textField: true,
      label: 'Mensaje adicional opcional',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          key: const ValueKey('additional-message-field'),
          duration: AppMotion.fieldFocus,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: AppSurfaces.card(selected: focused),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mensaje (opcional)',
                style: AppTypography.auxiliary.copyWith(
                  color: focused ? AppColors.gpaCrimson : AppColors.graphite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: IgnorePointer(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    readOnly: true,
                    showCursor: focused,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTypography.field,
                    decoration: InputDecoration(
                      hintText:
                          'Escribe aquí cualquier comentario o necesidad específica…',
                      hintStyle: AppTypography.field.copyWith(
                        color: AppColors.steel,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${controller.text.length}/$maximumLength',
                  style: AppTypography.auxiliary.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
