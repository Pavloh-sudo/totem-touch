import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/registration_session.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../../../shared/mascot/gp_mascot.dart';
import '../domain/interest_navigator.dart';
import '../domain/interest_node.dart';
import 'widgets/interest_options_grid.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({
    required this.navigator,
    required this.onBackToRegistration,
    required this.onMascotStateChanged,
    required this.onSave,
    required this.onCompleted,
    super.key,
  });

  final InterestNavigator navigator;
  final VoidCallback onBackToRegistration;
  final ValueChanged<GpMascotState> onMascotStateChanged;
  final Future<RegistrationSession> Function(
    List<FinalInterestSelection> selections,
  )
  onSave;
  final Future<void> Function(RegistrationSession session) onCompleted;

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  InterestNode? _selectedNode;
  FinalInterestSelection? _recentSelection;
  bool _busy = false;
  bool _showSuccess = false;
  bool _saving = false;

  void _play(SoundEffect effect) {
    final controller = SoundControllerScope.maybeOf(context);
    if (controller != null) unawaited(controller.play(effect));
  }

  void _goBack() {
    if (_busy) return;
    if (!widget.navigator.back()) widget.onBackToRegistration();
    widget.onMascotStateChanged(GpMascotState.idle);
  }

  void _selectNode(InterestNode node) {
    if (_busy) return;
    _play(SoundEffect.selection);
    setState(() {
      _busy = true;
      _selectedNode = node;
      _showSuccess = false;
    });
    widget.onMascotStateChanged(GpMascotState.guide);
    unawaited(_finishNodeSelection(node));
  }

  Future<void> _finishNodeSelection(InterestNode node) async {
    await Future<void>.delayed(AppMotion.interestUnselected);
    if (!mounted) return;

    final finalSelection = widget.navigator.select(node);
    if (finalSelection == null) {
      setState(() {
        _busy = false;
        _selectedNode = null;
      });
      widget.onMascotStateChanged(GpMascotState.idle);
      return;
    }

    setState(() => _showSuccess = true);
    widget.onMascotStateChanged(GpMascotState.celebrate);
    await Future<void>.delayed(AppMotion.standard);
    if (!mounted) return;
    setState(() {
      _showSuccess = false;
      _recentSelection = finalSelection;
    });
  }

  void _continueSelecting() {
    if (_saving) return;
    setState(() {
      _recentSelection = null;
      _selectedNode = null;
      _busy = false;
      _showSuccess = false;
    });
    widget.onMascotStateChanged(GpMascotState.guide);
  }

  void _finishRegistration() {
    if (_saving || widget.navigator.selections.isEmpty) return;
    setState(() {
      _saving = true;
      _busy = true;
    });
    unawaited(_saveSelections());
  }

  Future<void> _saveSelections() async {
    try {
      late RegistrationSession completedSession;
      await Future.wait([
        widget.onSave(widget.navigator.selections).then((session) {
          completedSession = session;
        }),
        Future<void>.delayed(AppMotion.interestSaving),
      ]);
      if (!mounted) return;
      await widget.onCompleted(completedSession);
    } catch (_) {
      if (!mounted) return;
      _play(SoundEffect.error);
      widget.onMascotStateChanged(GpMascotState.error);
      setState(() {
        _busy = _recentSelection != null;
        _saving = false;
        _selectedNode = null;
        _showSuccess = false;
      });
    }
  }

  String _breadcrumbText(List<InterestNode> breadcrumb) {
    if (breadcrumb.isEmpty) return 'Áreas de interés';
    final visible = breadcrumb.length <= 2
        ? breadcrumb
        : breadcrumb.sublist(breadcrumb.length - 2);
    final prefix = breadcrumb.length > 2 ? '…  ›  ' : '';
    return '$prefix${visible.map((node) => node.title).join('  ›  ')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.navigator,
      builder: (context, child) {
        final navigator = widget.navigator;
        final isRoot = navigator.isAtRoot;
        final levelKey = navigator.currentNode?.id ?? 'root';
        final selectedNodeIds = {
          ...navigator.selections.map((selection) => selection.leaf.id),
          if (_selectedNode case final node?) node.id,
        };

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GpaIconButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: isRoot
                          ? 'Volver al registro'
                          : 'Volver al nivel anterior',
                      sound: SoundEffect.back,
                      onPressed: _busy ? null : _goBack,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _breadcrumbText(navigator.breadcrumb),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.auxiliary.copyWith(
                              color: isRoot
                                  ? AppColors.graphite
                                  : AppColors.gpaCrimson,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRoot
                                ? '¿Qué te gustaría explorar?'
                                : '¿Qué opciones te interesan?',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.screenTitle.copyWith(
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRoot
                                ? 'Elige un área para ver sus opciones.'
                                : 'Puedes elegir más de una opción.',
                            style: AppTypography.body.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    if (navigator.selectionCount > 0)
                      _SelectionCountBadge(count: navigator.selectionCount),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.standard,
                    switchInCurve: AppMotion.standardCurve,
                    switchOutCurve: AppMotion.standardCurve,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0.015, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: Align(
                      key: ValueKey('interest-level-$levelKey'),
                      alignment: Alignment.topCenter,
                      child: InterestOptionsGrid(
                        nodes: navigator.options,
                        selectedNodeIds: selectedNodeIds,
                        activeNode: _selectedNode,
                        showSuccess: _showSuccess,
                        enabled: !_busy,
                        onSelected: _selectNode,
                      ),
                    ),
                  ),
                ),
                if (navigator.selectionCount > 0 && _recentSelection == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _SelectedInterestsBar(
                      count: navigator.selectionCount,
                      onFinish: _saving ? null : _finishRegistration,
                    ),
                  ),
              ],
            ),
            if (_recentSelection case final selection?)
              Positioned.fill(
                child: _ContinueOrFinishOverlay(
                  selection: selection,
                  total: navigator.selectionCount,
                  saving: _saving,
                  onContinue: _continueSelecting,
                  onFinish: _finishRegistration,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SelectionCountBadge extends StatelessWidget {
  const _SelectionCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('interest-selection-count'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.gpaCrimson.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${count == 1 ? 'selección' : 'selecciones'}',
        style: AppTypography.auxiliary.copyWith(
          color: AppColors.gpaCrimson,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SelectedInterestsBar extends StatelessWidget {
  const _SelectedInterestsBar({required this.count, required this.onFinish});

  final int count;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('selected-interests-bar'),
      height: 58,
      padding: const EdgeInsets.only(left: 18, right: 4),
      decoration: AppSurfaces.card(selected: false),
      child: Row(
        children: [
          const Icon(Icons.bookmark_added_rounded, color: AppColors.techCyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'interés guardado' : 'intereses guardados'}',
              style: AppTypography.label,
            ),
          ),
          SizedBox(
            width: 180,
            child: GpaPrimaryButton(
              label: 'Terminar',
              icon: Icons.arrow_forward_rounded,
              trailingIcon: true,
              height: 50,
              sound: SoundEffect.selection,
              onPressed: onFinish,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueOrFinishOverlay extends StatelessWidget {
  const _ContinueOrFinishOverlay({
    required this.selection,
    required this.total,
    required this.saving,
    required this.onContinue,
    required this.onFinish,
  });

  final FinalInterestSelection selection;
  final int total;
  final bool saving;
  final VoidCallback onContinue;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
      builder: (context, progress, child) {
        return ColoredBox(
          color: AppColors.carbon.withValues(alpha: 0.32 * progress),
          child: Center(
            child: Opacity(
              opacity: progress,
              child: Transform.scale(
                scale: 0.96 + (0.04 * progress),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Container(
        key: const ValueKey('interest-continue-or-finish'),
        width: 570,
        padding: const EdgeInsets.all(28),
        decoration: AppSurfaces.card(selected: true),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.successGreen,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text('Interés agregado', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text(
              selection.leaf.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.gpaCrimson,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              total == 1
                  ? '¿Quieres seleccionar algo más o terminamos?'
                  : 'Ya llevas $total selecciones. ¿Agregamos otra?',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GpaSecondaryButton(
                    label: 'Elegir otra',
                    icon: Icons.add_rounded,
                    height: 62,
                    onPressed: saving ? null : onContinue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GpaPrimaryButton(
                    label: saving ? 'Guardando' : 'Terminar',
                    icon: Icons.arrow_forward_rounded,
                    trailingIcon: true,
                    height: 62,
                    state: saving
                        ? GpaButtonState.loading
                        : GpaButtonState.normal,
                    sound: SoundEffect.selection,
                    onPressed: saving ? null : onFinish,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
