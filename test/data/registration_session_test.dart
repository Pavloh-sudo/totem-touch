import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/data/models/registration_session.dart';

void main() {
  test('recupera registros anteriores con una sola ruta de interés', () {
    final session = RegistrationSession.fromJson({
      'sessionId': 'registro-anterior',
      'startedAt': '2026-08-26T10:00:00.000',
      'personType': null,
      'name': 'Pablo',
      'company': '',
      'email': 'pablo1@correo.com',
      'phone': '1111111111',
      'wantsInformation': false,
      'interestPath': ['Software Industrial', 'Sistemas Web'],
      'completedAt': '2026-08-26T10:02:00.000',
      'durationMilliseconds': 120000,
      'kioskId': 'totem-prueba',
      'eventId': 'evento-prueba',
    });

    expect(session.interestPaths, [
      ['Software Industrial', 'Sistemas Web'],
    ]);
  });

  test('serializa y recupera varias rutas de interés', () {
    final original = RegistrationSession.fromJson({
      'sessionId': 'registro-nuevo',
      'startedAt': '2026-08-26T10:00:00.000',
      'personType': null,
      'name': 'Pablo',
      'company': '',
      'email': 'pablo1@correo.com',
      'phone': '1111111111',
      'wantsInformation': false,
      'interestPath': ['Sistemas de Corte', 'Sistema de Corte con Plasma'],
      'interestPaths': [
        ['Sistemas de Corte', 'Sistema de Corte con Plasma'],
        ['Software Industrial', 'Sistemas Web'],
      ],
      'completedAt': '2026-08-26T10:02:00.000',
      'durationMilliseconds': 120000,
      'kioskId': 'totem-prueba',
      'eventId': 'evento-prueba',
    });

    final restored = RegistrationSession.fromJson(original.toJson());
    expect(restored.interestPaths, original.interestPaths);
    expect(restored.finalInterest, 'Sistemas Web');
  });
}
