import 'package:flutter/material.dart';

import '../../../app/kiosk_shell.dart';
import '../../../shared/feedback/gpa_progress_indicator.dart';
import '../../../shared/mascot/gp_mascot.dart';
import '../domain/interest_navigator.dart';
import '../domain/interest_tree.dart';
import 'interests_page.dart';
import 'widgets/interest_node_visuals.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({
    required this.onBack,
    required this.onContinue,
    required this.onSessionExpired,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<List<List<String>>> onContinue;
  final VoidCallback onSessionExpired;

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  late final InterestNavigator _navigator;
  GpMascotState _mascotState = GpMascotState.idle;

  @override
  void initState() {
    super.initState();
    _navigator = InterestNavigator(roots: InterestTree.roots);
  }

  void _setMascotState(GpMascotState state) {
    if (_mascotState == state) return;
    setState(() => _mascotState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _navigator,
      builder: (context, child) {
        return KioskShell(
          onSessionExpired: widget.onSessionExpired,
          progressStage: _navigator.isAtRoot
              ? KioskProgressStage.interest
              : KioskProgressStage.detail,
          headerCompanion: GpMascot(
            key: const ValueKey('interests-header-mascot'),
            size: 76,
            mascotContext: _navigator.mascotOutfit.context,
            state: _mascotState,
            playEntranceAnimation: false,
          ),
          child: InterestsPage(
            navigator: _navigator,
            onBackToRegistration: widget.onBack,
            onMascotStateChanged: _setMascotState,
            onContinue: (selections) {
              widget.onContinue(
                selections
                    .map(
                      (selection) => selection.path
                          .map((node) => node.title)
                          .toList(growable: false),
                    )
                    .toList(growable: false),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _navigator.dispose();
    super.dispose();
  }
}
