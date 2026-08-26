enum InterestAccent {
  robotics,
  cutting,
  manufacturing,
  machinery,
  software,
  careers,
}

enum InterestIcon {
  robotics,
  cutting,
  manufacturing,
  machinery,
  software,
  careers,
}

enum InterestIllustration {
  robot,
  energy,
  production,
  tools,
  computer,
  education,
}

enum InterestMascotOutfit {
  robotics,
  cutting,
  manufacturing,
  machinery,
  software,
  careers,
}

class InterestNode {
  const InterestNode({
    required this.id,
    required this.title,
    required this.icon,
    required this.illustration,
    required this.accent,
    this.description = '',
    this.mascotOutfit,
    this.children = const [],
  });

  final String id;
  final String title;
  final String description;
  final InterestIcon icon;
  final InterestIllustration illustration;
  final InterestAccent accent;
  final InterestMascotOutfit? mascotOutfit;
  final List<InterestNode> children;

  bool get isLeaf => children.isEmpty;
}
