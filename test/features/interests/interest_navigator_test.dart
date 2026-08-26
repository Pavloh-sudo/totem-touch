import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/features/interests/domain/interest_navigator.dart';
import 'package:totem_touch/features/interests/domain/interest_node.dart';
import 'package:totem_touch/features/interests/domain/interest_tree.dart';

void main() {
  test('el árbol contiene las seis áreas y las 41 opciones indicadas', () {
    expect(InterestTree.roots, hasLength(6));
    expect(
      InterestTree.roots.map((node) => node.children.length),
      orderedEquals([11, 4, 8, 7, 5, 6]),
    );
    expect(
      InterestTree.roots
          .expand((node) => node.children)
          .map((node) => node.id)
          .toSet(),
      hasLength(41),
    );
  });

  test('navega por hijos, conserva historial y reconoce la hoja final', () {
    final navigator = InterestNavigator(roots: InterestTree.roots);
    addTearDown(navigator.dispose);
    final robotics = InterestTree.roots.first;

    final branchResult = navigator.select(robotics);
    expect(branchResult, isNull);
    expect(navigator.currentNode, robotics);
    expect(navigator.depth, 1);
    expect(navigator.breadcrumb, [robotics]);
    expect(navigator.options, robotics.children);
    expect(navigator.mascotOutfit, InterestMascotOutfit.robotics);

    final leaf = robotics.children.first;
    final finalResult = navigator.select(leaf);
    expect(finalResult, isNotNull);
    expect(finalResult!.leaf, leaf);
    expect(finalResult.path, [robotics, leaf]);
    expect(navigator.depth, 1);

    expect(navigator.back(), isTrue);
    expect(navigator.isAtRoot, isTrue);
    expect(navigator.back(), isFalse);
  });

  test('la misma lógica admite ocho niveles sin cambiar la interfaz', () {
    InterestNode nodeAt(int level) {
      return InterestNode(
        id: 'nivel_$level',
        title: 'Nivel $level',
        icon: InterestIcon.robotics,
        illustration: InterestIllustration.robot,
        accent: InterestAccent.robotics,
        children: level == 8 ? const [] : [nodeAt(level + 1)],
      );
    }

    final navigator = InterestNavigator(roots: [nodeAt(1)]);
    addTearDown(navigator.dispose);
    for (var level = 1; level < 8; level++) {
      expect(navigator.select(navigator.options.single), isNull);
    }
    final result = navigator.select(navigator.options.single);

    expect(navigator.depth, 7);
    expect(result, isNotNull);
    expect(result!.path, hasLength(8));
    expect(result.leaf.id, 'nivel_8');
  });
}
