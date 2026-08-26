import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surfaces.dart';
import '../../../core/theme/app_typography.dart';
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
    required this.onContinue,
    super.key,
  });

  final InterestNavigator navigator;
  final VoidCallback onBackToRegistration;
  final ValueChanged<GpMascotState> onMascotStateChanged;
  final ValueChanged<List<FinalInterestSelection>> onContinue;

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  InterestNode? _selectedNode;
  bool _busy = false;
  bool _showSuccess = false;
  bool _showExploreMoreQuestion = false;

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
    final selecting = !node.isLeaf || !widget.navigator.isSelected(node);
    _play(selecting ? SoundEffect.selection : SoundEffect.back);
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

    if (!node.isLeaf) {
      widget.navigator.select(node);
      setState(() {
        _busy = false;
        _selectedNode = null;
      });
      widget.onMascotStateChanged(GpMascotState.idle);
      return;
    }

    final selected = widget.navigator.toggleLeaf(node);
    if (selected) {
      setState(() {
        _showSuccess = true;
      });
      widget.onMascotStateChanged(GpMascotState.celebrate);
      await Future<void>.delayed(AppMotion.standard);
      if (!mounted) return;
    }
    setState(() {
      _busy = false;
      _selectedNode = null;
      _showSuccess = false;
    });
    widget.onMascotStateChanged(GpMascotState.guide);
  }

  void _returnToAreas() {
    if (_busy || widget.navigator.selections.isEmpty) return;
    widget.navigator.back();
    setState(() => _showExploreMoreQuestion = widget.navigator.isAtRoot);
    widget.onMascotStateChanged(GpMascotState.thinking);
  }

  void _chooseAnotherArea() {
    setState(() => _showExploreMoreQuestion = false);
    widget.onMascotStateChanged(GpMascotState.guide);
  }

  void _continueFlow() {
    if (_busy || widget.navigator.selections.isEmpty) return;
    widget.onContinue(widget.navigator.selections);
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
        final hasSelections = navigator.selectionCount > 0;
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
                                ? hasSelections
                                      ? '¿Te gustaría explorar algo más?'
                                      : '¿Qué te gustaría explorar?'
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
                                ? hasSelections
                                      ? 'Puedes elegir otra área o continuar con tus selecciones.'
                                      : 'Elige un área para ver sus opciones.'
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
                if (navigator.selectionCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _SelectedInterestsBar(
                      count: navigator.selectionCount,
                      onContinue: _busy
                          ? null
                          : isRoot
                          ? _continueFlow
                          : _returnToAreas,
                    ),
                  ),
              ],
            ),
            if (_showExploreMoreQuestion)
              Positioned.fill(
                child: _ExploreMoreOverlay(
                  total: navigator.selectionCount,
                  onChooseMore: _chooseAnotherArea,
                  onContinue: _continueFlow,
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
  const _SelectedInterestsBar({required this.count, required this.onContinue});

  final int count;
  final VoidCallback? onContinue;

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
              '$count ${count == 1 ? 'opción seleccionada' : 'opciones seleccionadas'}',
              style: AppTypography.label,
            ),
          ),
          SizedBox(
            width: 210,
            child: GpaPrimaryButton(
              label: 'Continuar',
              icon: Icons.arrow_forward_rounded,
              trailingIcon: true,
              height: 50,
              sound: SoundEffect.selection,
              onPressed: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreMoreOverlay extends StatelessWidget {
  const _ExploreMoreOverlay({
    required this.total,
    required this.onChooseMore,
    required this.onContinue,
  });

  final int total;
  final VoidCallback onChooseMore;
  final VoidCallback onContinue;

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
        key: const ValueKey('interest-explore-more'),
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
                color: AppColors.techCyan.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: AppColors.techCyan,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tus intereses van tomando forma',
              style: AppTypography.screenTitle,
            ),
            const SizedBox(height: 8),
            Text(
              'Llevas $total ${total == 1 ? 'opción seleccionada' : 'opciones seleccionadas'}. '
              '¿Te gustaría explorar otra área?',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GpaSecondaryButton(
                    label: 'Elegir otra área',
                    icon: Icons.add_rounded,
                    height: 62,
                    onPressed: onChooseMore,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GpaPrimaryButton(
                    label: 'Continuar',
                    icon: Icons.arrow_forward_rounded,
                    trailingIcon: true,
                    height: 62,
                    sound: SoundEffect.selection,
                    onPressed: onContinue,
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
