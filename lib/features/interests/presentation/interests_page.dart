import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/audio/sound_effect.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/interest_submission.dart';
import '../../../data/models/visitor_registration.dart';
import '../../../shared/buttons/gpa_buttons.dart';
import '../../../shared/mascot/gp_mascot.dart';
import '../domain/interest_navigator.dart';
import '../domain/interest_node.dart';
import 'widgets/interest_options_grid.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({
    required this.registration,
    required this.navigator,
    required this.onBackToRegistration,
    required this.onMascotStateChanged,
    required this.onSave,
    required this.onCompleted,
    super.key,
  });

  final VisitorRegistration registration;
  final InterestNavigator navigator;
  final VoidCallback onBackToRegistration;
  final ValueChanged<GpMascotState> onMascotStateChanged;
  final Future<void> Function(InterestSubmission submission) onSave;
  final Future<void> Function(InterestSubmission submission) onCompleted;

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  InterestNode? _selectedNode;
  bool _busy = false;
  bool _showSuccess = false;

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
    final submission = _submissionFor(finalSelection);

    try {
      await Future.wait([
        widget.onSave(submission),
        Future<void>.delayed(AppMotion.interestSaving),
      ]);
      if (!mounted) return;
      _play(SoundEffect.success);
      await widget.onCompleted(submission);
    } catch (_) {
      if (!mounted) return;
      _play(SoundEffect.error);
      widget.onMascotStateChanged(GpMascotState.error);
      setState(() {
        _busy = false;
        _selectedNode = null;
        _showSuccess = false;
      });
    }
  }

  InterestSubmission _submissionFor(FinalInterestSelection selection) {
    final now = DateTime.now();
    return InterestSubmission(
      id: '${now.microsecondsSinceEpoch}-${selection.leaf.id}',
      registration: widget.registration,
      pathIds: List.unmodifiable(selection.path.map((node) => node.id)),
      pathTitles: List.unmodifiable(selection.path.map((node) => node.title)),
      createdAt: now,
    );
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

        return Column(
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
                            : '¿Qué opción te interesa?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.screenTitle.copyWith(fontSize: 30),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRoot
                            ? 'Elige el área que más te interesa.'
                            : 'Elige una opción para continuar.',
                        style: AppTypography.body.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
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
                    selectedNode: _selectedNode,
                    showSuccess: _showSuccess,
                    enabled: !_busy,
                    onSelected: _selectNode,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
