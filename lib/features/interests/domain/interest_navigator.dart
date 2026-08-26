import 'package:flutter/foundation.dart';

import 'interest_node.dart';

class FinalInterestSelection {
  const FinalInterestSelection({required this.path, required this.leaf});

  final List<InterestNode> path;
  final InterestNode leaf;
}

class InterestNavigator extends ChangeNotifier {
  InterestNavigator({required List<InterestNode> roots})
    : _roots = List.unmodifiable(roots);

  final List<InterestNode> _roots;
  final List<InterestNode> _history = [];
  final List<FinalInterestSelection> _selections = [];

  List<InterestNode> get roots => _roots;
  List<InterestNode> get history => List.unmodifiable(_history);
  List<InterestNode> get breadcrumb => history;
  List<FinalInterestSelection> get selections => List.unmodifiable(_selections);
  int get selectionCount => _selections.length;
  int get depth => _history.length;
  bool get isAtRoot => _history.isEmpty;
  bool get canGoBack => _history.isNotEmpty;
  InterestNode? get currentNode => _history.isEmpty ? null : _history.last;
  List<InterestNode> get options => currentNode?.children ?? roots;

  bool isSelected(InterestNode node) {
    return _selections.any((selection) => selection.leaf.id == node.id);
  }

  InterestMascotOutfit? get mascotOutfit {
    for (final node in _history.reversed) {
      if (node.mascotOutfit case final outfit?) return outfit;
    }
    return null;
  }

  FinalInterestSelection? select(InterestNode node) {
    if (!options.contains(node)) {
      throw ArgumentError.value(
        node.id,
        'node',
        'No pertenece al nivel actual',
      );
    }
    if (node.isLeaf) {
      final existing = _selections.where(
        (selection) => selection.leaf.id == node.id,
      );
      if (existing.isNotEmpty) return existing.first;
      final selection = FinalInterestSelection(
        path: List.unmodifiable([..._history, node]),
        leaf: node,
      );
      _selections.add(selection);
      notifyListeners();
      return selection;
    }
    _history.add(node);
    notifyListeners();
    return null;
  }

  bool back() {
    if (_history.isEmpty) return false;
    _history.removeLast();
    notifyListeners();
    return true;
  }

  void reset() {
    if (_history.isEmpty && _selections.isEmpty) return;
    _history.clear();
    _selections.clear();
    notifyListeners();
  }
}
