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
      workbook['Intereses'].cell(CellIndex.indexByString('B7')).value,
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

    expect(registrationsXml, contains('<autoFilter ref="A5:T7"/>'));
    expect(interestsXml, contains('<autoFilter ref="A5:F7"/>'));
    expect(summaryXml, contains('<f>COUNTA('));
    expect(summaryXml, contains('<v>2</v>'));
    expect(archive.any((file) => file.name.startsWith('xl/media/')), isTrue);
  });
}

StoredRegistration _record({
  required int index,
  required String id,
  required List<String> path,
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
      company: 'GPA',
      email: 'persona$index@correo.com',
      phone: '1111111111',
      wantsInformation: index.isEven,
      interestPath: path,
      completedAt: completedAt,
      duration: const Duration(minutes: 2),
      kioskId: 'totem-prueba',
      eventId: 'evento-prueba',
    ),
  );
}
