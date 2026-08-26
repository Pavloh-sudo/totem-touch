import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/interest_node.dart';
import 'interest_node_visuals.dart';

class InterestOptionCard extends StatefulWidget {
  const InterestOptionCard({
    required this.node,
    required this.entryIndex,
    required this.selected,
    required this.dimmed,
    required this.compact,
    required this.showSuccess,
    required this.onPressed,
    super.key,
  });

  final InterestNode node;
  final int entryIndex;
  final bool selected;
  final bool dimmed;
  final bool compact;
  final bool showSuccess;
  final VoidCallback? onPressed;

  @override
  State<InterestOptionCard> createState() => _InterestOptionCardState();
}

class _InterestOptionCardState extends State<InterestOptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _entryOpacity;
  late final Animation<double> _entryScale;
  Timer? _entryTimer;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: AppMotion.interestCardEntry,
    );
    final curve = CurvedAnimation(
      parent: _entryController,
      curve: AppMotion.standardCurve,
    );
    _entryOpacity = curve;
    _entryScale = Tween(begin: 0.98, end: 1.0).animate(curve);
    final delay = AppMotion.interestCardStagger * widget.entryIndex;
    _entryTimer = Timer(delay, () {
      if (mounted) _entryController.forward();
    });
  }

  void _tapDown(TapDownDetails details) {
    if (widget.onPressed != null) setState(() => _pressed = true);
  }

  void _tapUp(TapUpDetails details) {
    if (!_pressed) return;
    setState(() => _pressed = false);
    widget.onPressed?.call();
  }

  void _tapCancel() {
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final selectionDuration = widget.selected
        ? AppMotion.interestSelected
        : AppMotion.interestUnselected;
    final selectionScale = widget.selected
        ? 1.025
        : widget.dimmed
        ? 0.97
        : 1.0;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Opacity(
          key: ValueKey('interest-entry-${node.id}'),
          opacity: _entryOpacity.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - _entryOpacity.value)),
            child: Transform.scale(scale: _entryScale.value, child: child),
          ),
        );
      },
      child: AnimatedOpacity(
        duration: AppMotion.interestUnselected,
        curve: AppMotion.standardCurve,
        opacity: widget.dimmed ? 0.15 : 1,
        child: AnimatedScale(
          duration: selectionDuration,
          curve: AppMotion.standardCurve,
          scale: selectionScale,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.onPressed == null ? null : _tapDown,
            onTapUp: widget.onPressed == null ? null : _tapUp,
            onTapCancel: widget.onPressed == null ? null : _tapCancel,
            child: AnimatedSlide(
              duration: _pressed ? AppMotion.touchDown : AppMotion.touchUp,
              curve: AppMotion.standardCurve,
              offset: Offset(0, _pressed ? 2 / 140 : 0),
              child: AnimatedScale(
                duration: _pressed ? AppMotion.touchDown : AppMotion.touchUp,
                curve: AppMotion.standardCurve,
                scale: _pressed ? 0.975 : 1,
                child: Semantics(
                  button: true,
                  selected: widget.selected,
                  label: '${node.title}. ${node.description}',
                  child: AnimatedContainer(
                    duration: selectionDuration,
                    curve: AppMotion.standardCurve,
                    clipBehavior: Clip.antiAlias,
                    decoration: AppSurfaces.card(selected: widget.selected),
                    child: AnimatedSwitcher(
                      duration: AppMotion.standard,
                      switchInCurve: AppMotion.standardCurve,
                      switchOutCurve: AppMotion.standardCurve,
                      child: widget.showSuccess
                          ? _SuccessContent(
                              key: ValueKey('interest-success-${node.id}'),
                              color: node.accentColor,
                            )
                          : _OptionContent(
                              key: ValueKey('interest-content-${node.id}'),
                              node: node,
                              compact: widget.compact,
                              selected: widget.selected,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entryTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }
}

class _OptionContent extends StatelessWidget {
  const _OptionContent({
    required this.node,
    required this.compact,
    required this.selected,
    super.key,
  });

  final InterestNode node;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final hasDescription = node.description.isNotEmpty;
    final iconSize = compact ? 38.0 : 42.0;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  node.accentColor.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: compact ? 10 : 18,
          bottom: compact ? 9 : 16,
          child: Icon(
            node.illustrationData,
            size: compact ? 58 : 78,
            color: node.accentColor.withValues(alpha: 0.11),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(height: compact ? 4 : 5, color: node.accentColor),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 20,
            compact ? 14 : 18,
            compact ? 14 : 18,
            compact ? 13 : 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: node.accentColor.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(compact ? 12 : 13),
                    ),
                    child: Icon(
                      node.iconData,
                      color: node.accentColor,
                      size: compact ? 21 : 24,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    node.isLeaf
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_rounded,
                    color: selected ? AppColors.gpaCrimson : AppColors.graphite,
                    size: compact ? 21 : 23,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                node.title,
                maxLines: compact ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  fontSize: compact ? 14 : 17,
                  height: compact ? 1.18 : 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasDescription) ...[
                const SizedBox(height: 5),
                Text(
                  node.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.auxiliary.copyWith(fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const ValueKey('interest-saving-check'),
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.13),
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(Icons.check_rounded, size: 42, color: color),
      ),
    );
  }
}
