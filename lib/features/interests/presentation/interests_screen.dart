import 'package:flutter/material.dart';

import '../../../app/kiosk_shell.dart';
import '../../../data/models/interest_submission.dart';
import '../../../data/models/visitor_registration.dart';
import '../../../data/repositories/interest_submission_repository.dart';
import '../../../shared/feedback/gpa_progress_indicator.dart';
import '../../../shared/mascot/gp_mascot.dart';
import '../domain/interest_navigator.dart';
import '../domain/interest_tree.dart';
import 'interests_page.dart';
import 'widgets/interest_node_visuals.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({
    required this.registration,
    required this.repository,
    required this.onBack,
    required this.onCompleted,
    super.key,
  });

  final VisitorRegistration registration;
  final InterestSubmissionRepository repository;
  final VoidCallback onBack;
  final Future<void> Function(InterestSubmission submission) onCompleted;

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
            registration: widget.registration,
            navigator: _navigator,
            onBackToRegistration: widget.onBack,
            onMascotStateChanged: _setMascotState,
            onSave: widget.repository.save,
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
