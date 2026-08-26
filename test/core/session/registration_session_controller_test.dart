import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/core/session/registration_session_controller.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';

void main() {
  test('forma la sesión completa, calcula duración y prepara un id nuevo', () {
    final times = [
      DateTime(2026, 8, 25, 10),
      DateTime(2026, 8, 25, 10, 3, 20),
    ].iterator;
    final ids = ['session-1', 'session-2'].iterator;
    final controller = RegistrationSessionController(
      clock: () {
        times.moveNext();
        return times.current;
      },
      idGenerator: () {
        ids.moveNext();
        return ids.current;
      },
      kioskId: 'kiosk-recepcion',
      eventId: 'expo-2026',
    );
    addTearDown(controller.dispose);

    controller.begin();
    controller.setRegistration(
      const VisitorRegistration(
        profile: VisitorProfile.company,
        name: 'Pablo',
        organization: 'Grupo GPA',
        email: 'pablo1@correo.com',
        phone: '1111111111',
        acceptsInformation: true,
      ),
    );
    final completed = controller.completeAll([
      ['Robótica & Automatización', 'Cobots', 'Integración'],
      ['Software Industrial', 'Sistemas Web'],
    ]);

    expect(completed.sessionId, 'session-1');
    expect(completed.personType, VisitorProfile.company);
    expect(completed.name, 'Pablo');
    expect(completed.company, 'Grupo GPA');
    expect(completed.email, 'pablo1@correo.com');
    expect(completed.phone, '1111111111');
    expect(completed.wantsInformation, isTrue);
    expect(completed.interestPath, [
      'Robótica & Automatización',
      'Cobots',
      'Integración',
    ]);
    expect(completed.interestPaths, [
      ['Robótica & Automatización', 'Cobots', 'Integración'],
      ['Software Industrial', 'Sistemas Web'],
    ]);
    expect(completed.finalInterest, 'Sistemas Web');
    expect(completed.completedAt, DateTime(2026, 8, 25, 10, 3, 20));
    expect(completed.duration, const Duration(minutes: 3, seconds: 20));
    expect(completed.kioskId, 'kiosk-recepcion');
    expect(completed.eventId, 'expo-2026');

    controller.resetForNextVisitor();
    expect(controller.current, isNull);
    expect(controller.hasActiveSession, isFalse);
    expect(controller.nextSessionId, 'session-2');
  });
}
