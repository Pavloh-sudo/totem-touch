import 'package:flutter/material.dart';

import '../../../app/kiosk_shell.dart';
import '../../../core/session/registration_session_controller.dart';
import '../../../data/models/registration_session.dart';
import '../../../data/repositories/interest_submission_repository.dart';
import '../../../shared/feedback/gpa_progress_indicator.dart';
import '../../../shared/mascot/gp_mascot.dart';
import '../domain/interest_navigator.dart';
import '../domain/interest_tree.dart';
import 'interests_page.dart';
import 'widgets/interest_node_visuals.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({
    required this.sessionController,
    required this.repository,
    required this.onBack,
    required this.onCompleted,
    required this.onSessionExpired,
    super.key,
  });

  final RegistrationSessionController sessionController;
  final InterestSubmissionRepository repository;
  final VoidCallback onBack;
  final Future<void> Function(RegistrationSession session) onCompleted;
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
            onSave: (selection) async {
              final session = widget.sessionController.complete(
                selection.path.map((node) => node.title).toList(),
              );
              await widget.repository.save(session);
              return session;
            },
            onCompleted: widget.onCompleted,
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
