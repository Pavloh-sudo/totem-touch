import 'package:flutter/material.dart';

import '../../core/theme/app_surfaces.dart';

class GpaSurfaceCard extends StatelessWidget {
  const GpaSurfaceCard({
    required this.child,
    this.selected = false,
    this.padding,
    this.onTap,
    super.key,
  });

  final Widget child;
  final bool selected;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: AnimatedContainer(
        duration: AppSurfaces.transitionDuration,
        curve: Curves.easeOutCubic,
        clipBehavior: Clip.antiAlias,
        decoration: AppSurfaces.card(selected: selected),
        child: onTap == null
            ? content
            : Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: content),
              ),
      ),
    );
  }
}
