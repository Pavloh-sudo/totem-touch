import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/interest_area.dart';
import 'interest_area_visuals.dart';

class InterestAreaCard extends StatefulWidget {
  const InterestAreaCard({
    required this.area,
    required this.entryIndex,
    required this.selected,
    required this.dimmed,
    required this.onPressed,
    super.key,
  });

  final InterestArea area;
  final int entryIndex;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onPressed;

  @override
  State<InterestAreaCard> createState() => _InterestAreaCardState();
}

class _InterestAreaCardState extends State<InterestAreaCard>
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
    final area = widget.area;
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
          key: ValueKey('interest-entry-${area.name}'),
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
              offset: Offset(0, _pressed ? 2 / 166 : 0),
              child: AnimatedScale(
                duration: _pressed ? AppMotion.touchDown : AppMotion.touchUp,
                curve: AppMotion.standardCurve,
                scale: _pressed ? 0.975 : 1,
                child: Semantics(
                  button: true,
                  selected: widget.selected,
                  label: '${area.title}. ${area.description}',
                  child: AnimatedContainer(
                    duration: selectionDuration,
                    curve: AppMotion.standardCurve,
                    clipBehavior: Clip.antiAlias,
                    decoration: AppSurfaces.card(selected: widget.selected),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                                colors: [
                                  area.accentColor.withValues(alpha: 0.06),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 18,
                          bottom: 16,
                          child: Icon(
                            area.illustration,
                            size: 78,
                            color: area.accentColor.withValues(alpha: 0.12),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(height: 5, color: area.accentColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: area.accentColor.withValues(
                                        alpha: 0.11,
                                      ),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      area.icon,
                                      color: area.accentColor,
                                      size: 24,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: widget.selected
                                        ? AppColors.gpaCrimson
                                        : AppColors.graphite,
                                    size: 23,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                area.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                area.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.auxiliary.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
