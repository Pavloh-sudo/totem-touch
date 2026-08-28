import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/registration_session.dart';

abstract interface class RegistrationRemoteGateway {
  Future<void> submit(RegistrationSession session);

  Future<bool> isAvailable();

  void close();
}

class RegistrationApiException implements Exception {
  const RegistrationApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'RegistrationApiException($statusCode): $message';
}

class RegistrationApiClient implements RegistrationRemoteGateway {
  RegistrationApiClient({
    required Uri baseUri,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 6),
  }) : _baseUri = _withTrailingSlash(baseUri),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<void> submit(RegistrationSession session) async {
    final response = await _client
        .post(
          _baseUri.resolve('registro.php'),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(session.toJson()),
        )
        .timeout(requestTimeout);
    final payload = _decodeResponse(response);
    if ((response.statusCode != 200 && response.statusCode != 201) ||
        payload['ok'] != true ||
        payload['stored'] != true) {
      throw RegistrationApiException(
        payload['message'] as String? ?? 'El servidor rechazó el registro.',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _client
          .get(
            _baseUri.resolve('estado.php'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(requestTimeout);
      if (response.statusCode != 200) return false;
      return _decodeResponse(response)['ok'] == true;
    } on Object {
      return false;
    }
  }

  Map<String, Object?> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, Object?>.from(decoded);
    } on FormatException {
      // El error legible se construye abajo.
    }
    return {
      'ok': false,
      'message': 'La API devolvió una respuesta que no se pudo leer.',
    };
  }

  @override
  void close() => _client.close();

  static Uri _withTrailingSlash(Uri value) {
    final text = value.toString();
    return text.endsWith('/') ? value : Uri.parse('$text/');
  }
}
