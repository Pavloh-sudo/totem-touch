import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/configuration/kiosk_configuration.dart';
import '../core/session/registration_session_controller.dart';
import '../data/local/indexed_db_interest_submission_repository.dart';
import '../data/repositories/interest_submission_repository.dart';
import 'app_preloader.dart';
import 'app_router.dart';

class TotemTouchApp extends StatefulWidget {
  const TotemTouchApp({super.key});

  @override
  State<TotemTouchApp> createState() => _TotemTouchAppState();
}

class _TotemTouchAppState extends State<TotemTouchApp> {
  late final RegistrationSessionController _sessionController;
  late final InterestSubmissionRepository _interestRepository;

  @override
  void initState() {
    super.initState();
    _sessionController = RegistrationSessionController(
      kioskId: KioskConfiguration.kioskId,
      eventId: KioskConfiguration.eventId,
    );
    _interestRepository = IndexedDbInterestSubmissionRepository();
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationSessionScope(
      controller: _sessionController,
      child: MaterialApp(
        title: 'Tótem Touch GPA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.kiosk,
        initialRoute: AppRouter.attract,
        builder: (context, child) => AppPreloader(
          repository: _interestRepository,
          child: child ?? const SizedBox.shrink(),
        ),
        onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
          settings,
          repository: _interestRepository,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }
}
