import 'package:flutter/material.dart';

import '../../../app/kiosk_shell.dart';
import '../../../data/models/visitor_registration.dart';
import '../../../shared/feedback/gpa_progress_indicator.dart';
import '../../../shared/mascot/gp_mascot.dart';
import '../domain/interest_area.dart';
import 'interests_page.dart';
import 'widgets/interest_area_visuals.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({
    required this.registration,
    required this.onBack,
    this.onSelected,
    super.key,
  });

  final VisitorRegistration registration;
  final VoidCallback onBack;
  final Future<void> Function(InterestArea area)? onSelected;

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  GpMascotContext _mascotContext = GpMascotContext.defaultOutfit;
  GpMascotState _mascotState = GpMascotState.idle;

  void _showAreaContext(InterestArea area) {
    setState(() {
      _mascotContext = area.mascotContext;
      _mascotState = GpMascotState.guide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KioskShell(
      progressStage: KioskProgressStage.interest,
      headerCompanion: GpMascot(
        key: const ValueKey('interests-header-mascot'),
        size: 76,
        mascotContext: _mascotContext,
        state: _mascotState,
        playEntranceAnimation: false,
      ),
      child: InterestsPage(
        registration: widget.registration,
        onBack: widget.onBack,
        onSelectionStarted: _showAreaContext,
        onSelected: widget.onSelected,
      ),
    );
  }
}
