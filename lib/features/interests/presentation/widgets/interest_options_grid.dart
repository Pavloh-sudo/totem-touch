import 'package:flutter/material.dart';

import '../../domain/interest_node.dart';
import 'interest_option_card.dart';

class InterestGridMetrics {
  const InterestGridMetrics({
    required this.columns,
    required this.cardHeight,
    required this.maxCardHeight,
    required this.spacing,
    required this.compact,
  });

  final int columns;
  final double cardHeight;
  final double maxCardHeight;
  final double spacing;
  final bool compact;

  int rowsFor(int count) => (count / columns).ceil();

  static InterestGridMetrics resolve(int count) {
    if (count <= 2) {
      return InterestGridMetrics(
        columns: count.clamp(1, 2),
        cardHeight: 210,
        maxCardHeight: 250,
        spacing: 20,
        compact: false,
      );
    }
    if (count <= 4) {
      return const InterestGridMetrics(
        columns: 2,
        cardHeight: 180,
        maxCardHeight: 230,
        spacing: 20,
        compact: false,
      );
    }
    if (count <= 6) {
      return const InterestGridMetrics(
        columns: 3,
        cardHeight: 166,
        maxCardHeight: 215,
        spacing: 20,
        compact: false,
      );
    }
    if (count <= 9) {
      return const InterestGridMetrics(
        columns: 3,
        cardHeight: 132,
        maxCardHeight: 168,
        spacing: 14,
        compact: true,
      );
    }
    return const InterestGridMetrics(
      columns: 4,
      cardHeight: 132,
      maxCardHeight: 168,
      spacing: 14,
      compact: true,
    );
  }
}

class InterestOptionsGrid extends StatelessWidget {
  const InterestOptionsGrid({
    required this.nodes,
    required this.selectedNodeIds,
    required this.activeNode,
    required this.showSuccess,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final List<InterestNode> nodes;
  final Set<String> selectedNodeIds;
  final InterestNode? activeNode;
  final bool showSuccess;
  final bool enabled;
  final ValueChanged<InterestNode> onSelected;

  @override
  Widget build(BuildContext context) {
    final metrics = InterestGridMetrics.resolve(nodes.length);
    final rows = metrics.rowsFor(nodes.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - ((metrics.columns - 1) * metrics.spacing)) /
            metrics.columns;
        final spacingHeight = (rows - 1) * metrics.spacing;
        final availableCardHeight = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - spacingHeight) / rows
            : metrics.cardHeight;
        final shouldUseAvailableHeight = nodes.every((node) => node.isLeaf);
        final cardHeight = shouldUseAvailableHeight
            ? availableCardHeight
                  .clamp(metrics.cardHeight, metrics.maxCardHeight)
                  .toDouble()
            : metrics.cardHeight;
        final totalHeight = (rows * cardHeight) + spacingHeight;

        return SizedBox(
          height: totalHeight,
          child: Wrap(
            spacing: metrics.spacing,
            runSpacing: metrics.spacing,
            children: [
              for (var index = 0; index < nodes.length; index++)
                SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: InterestOptionCard(
                    key: ValueKey('interest-option-${nodes[index].id}'),
                    node: nodes[index],
                    entryIndex: index,
                    selected: selectedNodeIds.contains(nodes[index].id),
                    dimmed: activeNode != null && activeNode != nodes[index],
                    compact: metrics.compact,
                    showSuccess: showSuccess && activeNode == nodes[index],
                    onPressed: enabled && activeNode == null
                        ? () => onSelected(nodes[index])
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
