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

  List<InterestNode> get roots => _roots;
  List<InterestNode> get history => List.unmodifiable(_history);
  List<InterestNode> get breadcrumb => history;
  int get depth => _history.length;
  bool get isAtRoot => _history.isEmpty;
  bool get canGoBack => _history.isNotEmpty;
  InterestNode? get currentNode => _history.isEmpty ? null : _history.last;
  List<InterestNode> get options => currentNode?.children ?? roots;

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
      return FinalInterestSelection(
        path: List.unmodifiable([..._history, node]),
        leaf: node,
      );
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
    if (_history.isEmpty) return;
    _history.clear();
    notifyListeners();
  }
}
