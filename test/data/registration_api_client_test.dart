import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kiosco_gpa/data/models/registration_session.dart';
import 'package:kiosco_gpa/data/models/visitor_registration.dart';
import 'package:kiosco_gpa/data/remote/registration_api_client.dart';

void main() {
  test('envía todas las rutas y acepta registros nuevos o repetidos', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(
        jsonEncode({
          'ok': true,
          'stored': true,
          'duplicate': requests.length > 1,
        }),
        requests.length == 1 ? 201 : 200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = RegistrationApiClient(
      baseUri: Uri.parse('https://gpa.example/kiosco/api/'),
      client: client,
    );
    addTearDown(api.close);

    final session = _session();
    await api.submit(session);
    await api.submit(session);

    expect(requests, hasLength(2));
    expect(
      requests.first.url,
      Uri.parse('https://gpa.example/kiosco/api/registro.php'),
    );
    final payload = jsonDecode(requests.first.body) as Map<String, dynamic>;
    expect(payload['sessionId'], session.sessionId);
    expect(payload['interestPaths'], session.interestPaths);
    expect(payload['additionalMessage'], session.additionalMessage);
  });

  test('detecta cuando la API no está disponible', () async {
    final client = MockClient((_) async => http.Response('error', 500));
    final api = RegistrationApiClient(
      baseUri: Uri.parse('https://gpa.example/api'),
      client: client,
    );
    addTearDown(api.close);

    expect(await api.isAvailable(), isFalse);
    expect(
      () => api.submit(_session()),
      throwsA(isA<RegistrationApiException>()),
    );
  });
}

RegistrationSession _session() {
  return RegistrationSession(
    sessionId: 'GPA-20260827-550E8400-E29B-41D4-A716-446655440000',
    startedAt: DateTime(2026, 8, 27, 10),
    personType: VisitorProfile.professional,
    name: 'Pablo',
    company: 'GPA',
    email: 'pablo25@correo.com',
    phone: '6141234567',
    wantsInformation: true,
    interestPath: const [
      'Robótica & Automatización',
      'Automatización con Robots',
    ],
    additionalInterestPaths: const [
      ['Software Industrial', 'Sistemas Web'],
    ],
    additionalMessage: 'Necesito más información.',
    completedAt: DateTime(2026, 8, 27, 10, 3),
    duration: const Duration(minutes: 3),
    kioskId: 'kiosco-prueba',
    eventId: 'evento-prueba',
  );
}
