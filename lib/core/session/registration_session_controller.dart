import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/registration_session.dart';
import '../../data/models/visitor_registration.dart';

class RegistrationSessionController extends ChangeNotifier {
  RegistrationSessionController({
    DateTime Function()? clock,
    String Function()? idGenerator,
    this.kioskId = 'kiosco-gpa-01',
    this.eventId = 'evento-gpa',
  }) : _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator ?? _SessionIdGenerator().next {
    _nextSessionId = _idGenerator();
  }

  final DateTime Function() _clock;
  final String Function() _idGenerator;
  final String kioskId;
  final String eventId;

  RegistrationSession? _current;
  late String _nextSessionId;

  RegistrationSession? get current => _current;
  bool get hasActiveSession => _current != null;
  String get nextSessionId => _nextSessionId;

  RegistrationSession begin() {
    if (_current != null) resetForNextVisitor();
    _current = RegistrationSession(
      sessionId: _nextSessionId,
      startedAt: _clock(),
      personType: null,
      name: '',
      company: '',
      email: '',
      phone: '',
      wantsInformation: false,
      interestPath: const [],
      additionalMessage: '',
      completedAt: null,
      duration: null,
      kioskId: kioskId,
      eventId: eventId,
    );
    notifyListeners();
    return _current!;
  }

  RegistrationSession setRegistration(VisitorRegistration registration) {
    final session = _requireCurrent();
    _current = session.withRegistration(registration);
    notifyListeners();
    return _current!;
  }

  RegistrationSession complete(List<String> interestPath) {
    return completeAll([interestPath]);
  }

  RegistrationSession completeAll(
    List<List<String>> interestPaths, {
    String additionalMessage = '',
  }) {
    final session = _requireCurrent();
    if (session.personType == null) {
      throw StateError('La sesión todavía no tiene datos de registro.');
    }
    if (interestPaths.isEmpty || interestPaths.any((path) => path.isEmpty)) {
      throw ArgumentError.value(interestPaths, 'interestPaths');
    }
    _current = session.completeAll(
      paths: interestPaths,
      at: _clock(),
      additionalMessage: additionalMessage,
    );
    notifyListeners();
    return _current!;
  }

  void resetForNextVisitor() {
    _current = null;
    _nextSessionId = _idGenerator();
    notifyListeners();
  }

  RegistrationSession _requireCurrent() {
    final session = _current;
    if (session == null) throw StateError('No existe una sesión activa.');
    return session;
  }
}

class RegistrationSessionScope
    extends InheritedNotifier<RegistrationSessionController> {
  const RegistrationSessionScope({
    required RegistrationSessionController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static RegistrationSessionController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RegistrationSessionScope>();
    assert(scope != null, 'No existe RegistrationSessionScope.');
    return scope!.notifier!;
  }
}

class _SessionIdGenerator {
  final Uuid _uuid = const Uuid();

  String next() {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return 'GPA-$date-${_uuid.v4().toUpperCase()}';
  }
}
