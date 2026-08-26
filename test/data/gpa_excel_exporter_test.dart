import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel_community/excel_community.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_touch/data/export/gpa_excel_exporter.dart';
import 'package:totem_touch/data/models/registration_session.dart';
import 'package:totem_touch/data/models/stored_registration.dart';
import 'package:totem_touch/data/models/visitor_registration.dart';

void main() {
  test('genera las tres hojas con logo, filtros y resumen', () {
    final logoBytes = Uint8List.fromList(
      File('assets/branding/gpa_logo.png').readAsBytesSync(),
    );
    final records = [
      _record(
        index: 1,
        id: 'GPA-20260826-11111111-1111-4111-8111-111111111111',
        path: const ['Robótica & Automatización', 'Automatización con Robots'],
        additionalPaths: const [
          ['Robótica & Automatización', 'Automatización con Cobots'],
        ],
        additionalMessage: 'Necesito una demostración en planta.',
      ),
      _record(
        index: 2,
        id: 'GPA-20260826-22222222-2222-4222-8222-222222222222',
        path: const ['Sistemas de Corte', 'Sistema de Corte con Láser'],
      ),
    ];

    final bytes = const GpaExcelExporter().buildWithLogo(records, logoBytes);
    final workbook = Excel.decodeBytes(bytes);

    expect(
      workbook.tables.keys,
      containsAll(['Registros', 'Intereses', 'Resumen']),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('A6')).value,
      TextCellValue(records.first.session.sessionId),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('C6')).value,
      isA<DateCellValue>(),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('D6')).value,
      isA<TimeCellValue>(),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('E5')).value,
      TextCellValue('Nombre'),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('F5')).value,
      TextCellValue('Tipo'),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('G5')).value,
      TextCellValue('Empresa / institución'),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('L5')).value,
      TextCellValue('Intereses seleccionados'),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('M5')).value,
      TextCellValue('Comentario adicional'),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('M6')).value,
      TextCellValue('Necesito una demostración en planta.'),
    );
    expect(
      workbook['Intereses'].cell(CellIndex.indexByString('D8')).value,
      TextCellValue('Sistemas de Corte'),
    );
    expect(
      workbook['Resumen'].cell(CellIndex.indexByString('A6')).value,
      isA<FormulaCellValue>(),
    );

    final archive = ZipDecoder().decodeBytes(bytes);
    final registrationsXml = utf8.decode(
      archive.find('xl/worksheets/sheet1.xml')!.content,
    );
    final interestsXml = utf8.decode(
      archive.find('xl/worksheets/sheet2.xml')!.content,
    );
    final summaryXml = utf8.decode(
      archive.find('xl/worksheets/sheet3.xml')!.content,
    );
    final stylesXml = utf8.decode(archive.find('xl/styles.xml')!.content);
    final sharedStringsXml = utf8.decode(
      archive.find('xl/sharedStrings.xml')!.content,
    );

    expect(registrationsXml, contains('<autoFilter ref="A5:R7"/>'));
    expect(interestsXml, contains('<autoFilter ref="A5:H8"/>'));
    expect(summaryXml, contains('<f>COUNTA('));
    expect(summaryXml, contains('<v>3</v>'));
    expect(summaryXml, contains('<v>2</v>'));
    final fillCount = int.parse(
      RegExp(r'<fills count="(\d+)">').firstMatch(stylesXml)!.group(1)!,
    );
    expect(RegExp(r'<fill>').allMatches(stylesXml).length, fillCount);
    for (final match in RegExp(r'rgb="([A-F0-9]+)"').allMatches(stylesXml)) {
      expect(match.group(1), hasLength(8));
    }
    expect(sharedStringsXml, isNot(contains('<t xml:space="preserve"></t>')));
    expect(archive.any((file) => file.name.startsWith('xl/media/')), isTrue);
  });

  test('exporta muchos registros sin perder filas ni encabezados', () {
    final logoBytes = Uint8List.fromList(
      File('assets/branding/gpa_logo.png').readAsBytesSync(),
    );
    final records = List.generate(
      250,
      (index) => _record(
        index: index + 1,
        id: 'registro-${index + 1}',
        path: const ['Software Industrial', 'Sistemas Web'],
      ),
    );

    final bytes = const GpaExcelExporter().buildWithLogo(records, logoBytes);
    final workbook = Excel.decodeBytes(bytes);

    expect(
      workbook['Registros'].cell(CellIndex.indexByString('E5')).value,
      TextCellValue('Nombre'),
    );
    expect(
      workbook['Registros'].cell(CellIndex.indexByString('A255')).value,
      TextCellValue('registro-250'),
    );
    expect(
      workbook['Intereses'].cell(CellIndex.indexByString('A255')).value,
      TextCellValue('registro-250'),
    );
  });
}

StoredRegistration _record({
  required int index,
  required String id,
  required List<String> path,
  List<List<String>> additionalPaths = const [],
  String additionalMessage = '',
}) {
  final completedAt = DateTime(2026, 8, 26, 14, 32, index);
  return StoredRegistration(
    localIndex: index,
    savedAt: completedAt,
    syncStatus: RegistrationSyncStatus.pending,
    session: RegistrationSession(
      sessionId: id,
      startedAt: completedAt.subtract(const Duration(minutes: 2)),
      personType: VisitorProfile.professional,
      name: 'Persona $index',
      company: index.isOdd ? '' : 'GPA',
      email: 'persona$index@correo.com',
      phone: '1111111111',
      wantsInformation: index.isEven,
      interestPath: path,
      additionalInterestPaths: additionalPaths,
      additionalMessage: additionalMessage,
      completedAt: completedAt,
      duration: const Duration(minutes: 2),
      kioskId: 'totem-prueba',
      eventId: 'evento-prueba',
    ),
  );
}
