import 'dart:convert';
import 'dart:math' as math;

import 'package:archive/archive.dart';
import 'package:excel_community/excel_community.dart';
import 'package:flutter/services.dart';

import '../../core/configuration/asset_paths.dart';
import '../models/stored_registration.dart';
import 'excel_download.dart';

class GpaExcelExporter {
  const GpaExcelExporter();

  static const _areas = [
    'Robótica & Automatización',
    'Sistemas de Corte',
    'Fabricación Avanzada',
    'Maquinaria a la Medida',
    'Software Industrial',
    'Vacantes & Estadías',
  ];

  Future<List<int>> build(List<StoredRegistration> records) async {
    final logoData = await rootBundle.load(AssetPaths.gpaLogo);
    return buildWithLogo(records, logoData.buffer.asUint8List());
  }

  List<int> buildWithLogo(
    List<StoredRegistration> records,
    Uint8List logoBytes,
  ) {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Registros');
    final registrations = excel['Registros'];
    final interests = excel['Intereses'];
    final summary = excel['Resumen'];

    _buildRegistrations(registrations, records, logoBytes);
    _buildInterests(interests, records, logoBytes);
    final formulaValues = _buildSummary(summary, records, logoBytes);

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('No se pudo construir el archivo de Excel.');
    }
    return _finishWorkbook(bytes, records.length, formulaValues);
  }

  Future<String> download(List<StoredRegistration> records) async {
    final bytes = await build(records);
    final now = DateTime.now();
    final fileName = 'registros_gpa_${_compactTimestamp(now)}.xlsx';
    downloadExcel(bytes, fileName);
    return fileName;
  }

  void _buildRegistrations(
    Sheet sheet,
    List<StoredRegistration> records,
    Uint8List logoBytes,
  ) {
    const headers = [
      'ID',
      'Índice',
      'Fecha',
      'Hora',
      'Nombre',
      'Perfil',
      'Empresa',
      'Correo',
      'Teléfono',
      'Recibir info',
      'Área',
      'Nivel 2',
      'Nivel 3',
      'Nivel 4',
      'Selección final',
      'Estado',
      'Timestamp',
      'Duración (s)',
      'Kiosco',
      'Evento',
    ];
    _addBrandHeader(
      sheet,
      logoBytes,
      title: 'REGISTRO DE INTERESES',
      subtitle: 'Grupo GPA',
      lastColumn: headers.length - 1,
    );
    _writeHeaderRow(sheet, headers, row: 4);

    for (var index = 0; index < records.length; index++) {
      final record = records[index];
      final session = record.session;
      final completedAt = session.completedAt ?? record.savedAt;
      final path = session.interestPath;
      final values = <CellValue?>[
        TextCellValue(session.sessionId),
        IntCellValue(record.localIndex),
        DateCellValue.fromDateTime(completedAt),
        TimeCellValue.fromTimeOfDateTime(completedAt),
        TextCellValue(session.name),
        TextCellValue(session.personType?.label ?? ''),
        TextCellValue(session.company),
        TextCellValue(session.email),
        TextCellValue(session.phone),
        TextCellValue(session.wantsInformation ? 'Sí' : 'No'),
        TextCellValue(_pathValue(path, 0)),
        TextCellValue(_pathValue(path, 1)),
        TextCellValue(_pathValue(path, 2)),
        TextCellValue(_pathValue(path, 3)),
        TextCellValue(path.isEmpty ? '' : path.last),
        TextCellValue(
          record.syncStatus == RegistrationSyncStatus.synced
              ? 'Sincronizado'
              : 'Pendiente',
        ),
        DateTimeCellValue.fromDateTime(completedAt),
        IntCellValue(session.duration?.inSeconds ?? 0),
        TextCellValue(session.kioskId),
        TextCellValue(session.eventId),
      ];
      _writeDataRow(sheet, values, row: index + 5, alternate: index.isOdd);
    }

    sheet.frozenRows = 5;
    _setWidths(sheet, const [
      48,
      9,
      13,
      12,
      24,
      17,
      25,
      30,
      18,
      16,
      28,
      34,
      34,
      34,
      42,
      16,
      25,
      14,
      18,
      20,
    ]);
  }

  void _buildInterests(
    Sheet sheet,
    List<StoredRegistration> records,
    Uint8List logoBytes,
  ) {
    const headers = [
      'Registro ID',
      'Área',
      'Nivel 2',
      'Nivel 3',
      'Nivel 4',
      'Selección final',
    ];
    _addBrandHeader(
      sheet,
      logoBytes,
      title: 'RUTAS DE INTERÉS',
      subtitle: 'Detalle completo de cada selección',
      lastColumn: headers.length - 1,
    );
    _writeHeaderRow(sheet, headers, row: 4);

    for (var index = 0; index < records.length; index++) {
      final session = records[index].session;
      final path = session.interestPath;
      _writeDataRow(
        sheet,
        [
          TextCellValue(session.sessionId),
          TextCellValue(_pathValue(path, 0)),
          TextCellValue(_pathValue(path, 1)),
          TextCellValue(_pathValue(path, 2)),
          TextCellValue(_pathValue(path, 3)),
          TextCellValue(path.isEmpty ? '' : path.last),
        ],
        row: index + 5,
        alternate: index.isOdd,
      );
    }

    sheet.frozenRows = 5;
    _setWidths(sheet, const [48, 30, 38, 38, 38, 45]);
  }

  Map<String, num> _buildSummary(
    Sheet sheet,
    List<StoredRegistration> records,
    Uint8List logoBytes,
  ) {
    _addBrandHeader(
      sheet,
      logoBytes,
      title: 'RESUMEN DE INTERESES',
      subtitle: 'Grupo GPA',
      lastColumn: 6,
    );

    final total = records.length;
    sheet.merge(CellIndex.indexByString('A5'), CellIndex.indexByString('C5'));
    sheet.updateCell(
      CellIndex.indexByString('A5'),
      TextCellValue('TOTAL REGISTROS'),
      cellStyle: _summaryLabelStyle,
    );
    sheet.merge(CellIndex.indexByString('A6'), CellIndex.indexByString('C8'));
    sheet.updateCell(
      CellIndex.indexByString('A6'),
      const FormulaCellValue("=COUNTA('Registros'!A6:A100000)"),
      cellStyle: _totalStyle,
    );

    _writeHeaderRow(sheet, const ['Área', 'Registros', 'Porcentaje'], row: 10);
    final formulaValues = <String, num>{'A6': total};
    for (var index = 0; index < _areas.length; index++) {
      final row = index + 11;
      final area = _areas[index];
      final count = records
          .where((record) => record.session.interestPath.firstOrNull == area)
          .length;
      final percentage = total == 0 ? 0.0 : count / total;
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
        TextCellValue(area),
        cellStyle: index.isOdd ? _alternateStyle : _bodyStyle,
      );
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
        FormulaCellValue("=COUNTIF('Registros'!K6:K100000,\"$area\")"),
        cellStyle: index.isOdd ? _alternateCenteredStyle : _centeredStyle,
      );
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
        FormulaCellValue('=IF(\$A\$6=0,0,B${row + 1}/\$A\$6)'),
        cellStyle: (index.isOdd ? _alternateCenteredStyle : _centeredStyle)
            .copyWith(
              numberFormat: const CustomNumericNumFormat(formatCode: '0.0%'),
            ),
      );
      formulaValues['B${row + 1}'] = count;
      formulaValues['C${row + 1}'] = percentage;
      sheet.setRowHeight(row, 25);
    }

    sheet.updateCell(
      CellIndex.indexByString('A20'),
      TextCellValue(
        'Los porcentajes se calculan sobre el total de registros exportados.',
      ),
      cellStyle: _noteStyle,
    );
    sheet.merge(CellIndex.indexByString('A20'), CellIndex.indexByString('C20'));
    sheet.frozenRows = 11;
    _setWidths(sheet, const [34, 16, 16, 3, 16, 16, 16]);
    return formulaValues;
  }

  void _addBrandHeader(
    Sheet sheet,
    Uint8List logoBytes, {
    required String title,
    required String subtitle,
    required int lastColumn,
  }) {
    sheet.addImage(
      ExcelImage(
        imageBytes: logoBytes,
        imageType: ExcelImageType.png,
        anchor: ImageAnchor.fromPixels(
          column: 0,
          row: 0,
          widthPixels: 82,
          heightPixels: 82,
        ),
      ),
    );
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: 1),
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
      TextCellValue(title),
      cellStyle: _titleStyle,
    );
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2),
      CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: 2),
    );
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2),
      TextCellValue(subtitle),
      cellStyle: _subtitleStyle,
    );
    sheet.setRowHeight(0, 28);
    sheet.setRowHeight(1, 28);
    sheet.setRowHeight(2, 24);
    sheet.setRowHeight(3, 10);
  }

  void _writeHeaderRow(Sheet sheet, List<String> headers, {required int row}) {
    for (var column = 0; column < headers.length; column++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
        TextCellValue(headers[column]),
        cellStyle: _headerStyle,
      );
    }
    sheet.setRowHeight(row, 29);
  }

  void _writeDataRow(
    Sheet sheet,
    List<CellValue?> values, {
    required int row,
    required bool alternate,
  }) {
    for (var column = 0; column < values.length; column++) {
      var style = alternate ? _alternateStyle : _bodyStyle;
      if (column == 1 || column == 9 || column == 15 || column == 17) {
        style = alternate ? _alternateCenteredStyle : _centeredStyle;
      }
      if (column == 2) {
        style = style.copyWith(
          numberFormat: const CustomDateTimeNumFormat(formatCode: 'dd/mm/yyyy'),
        );
      } else if (column == 3) {
        style = style.copyWith(
          numberFormat: const CustomTimeNumFormat(formatCode: 'hh:mm:ss'),
        );
      } else if (column == 16) {
        style = style.copyWith(
          numberFormat: const CustomDateTimeNumFormat(
            formatCode: 'dd/mm/yyyy hh:mm:ss',
          ),
        );
      }
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
        values[column],
        cellStyle: style,
      );
    }
    sheet.setRowHeight(row, 24);
  }

  void _setWidths(Sheet sheet, List<double> widths) {
    for (var index = 0; index < widths.length; index++) {
      sheet.setColumnWidth(index, widths[index]);
    }
  }

  List<int> _finishWorkbook(
    List<int> bytes,
    int recordCount,
    Map<String, num> summaryFormulaValues,
  ) {
    final archive = ZipDecoder().decodeBytes(bytes);
    _addFilter(
      archive,
      'xl/worksheets/sheet1.xml',
      'A5:T${math.max(5, recordCount + 5)}',
    );
    _addFilter(
      archive,
      'xl/worksheets/sheet2.xml',
      'A5:F${math.max(5, recordCount + 5)}',
    );
    _addFormulaCaches(
      archive,
      'xl/worksheets/sheet3.xml',
      summaryFormulaValues,
    );
    return ZipEncoder().encodeBytes(archive);
  }

  void _addFilter(Archive archive, String path, String reference) {
    final file = archive.find(path);
    if (file == null) return;
    var xml = utf8.decode(file.content);
    if (xml.contains('<autoFilter')) return;
    const markers = ['<mergeCells', '<pageMargins', '<drawing', '</worksheet>'];
    final marker = markers.firstWhere(xml.contains);
    xml = xml.replaceFirst(marker, '<autoFilter ref="$reference"/>$marker');
    archive.add(ArchiveFile.string(path, xml));
  }

  void _addFormulaCaches(
    Archive archive,
    String path,
    Map<String, num> values,
  ) {
    final file = archive.find(path);
    if (file == null) return;
    var xml = utf8.decode(file.content);
    final formulaCell = RegExp(
      r'<c r="([A-Z]+[0-9]+)"([^>]*)><f>(.*?)</f><v></v></c>',
    );
    xml = xml.replaceAllMapped(formulaCell, (match) {
      final address = match.group(1)!;
      final cached = values[address];
      final formula = match.group(3)!.replaceFirst(RegExp(r'^='), '');
      final cacheText = cached == null ? '' : _excelNumber(cached);
      return '<c r="$address"${match.group(2)!}><f>$formula</f><v>$cacheText</v></c>';
    });
    archive.add(ArchiveFile.string(path, xml));
  }

  String _pathValue(List<String> path, int index) {
    return index < path.length ? path[index] : '';
  }

  String _compactTimestamp(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}'
        '${value.month.toString().padLeft(2, '0')}'
        '${value.day.toString().padLeft(2, '0')}_'
        '${value.hour.toString().padLeft(2, '0')}'
        '${value.minute.toString().padLeft(2, '0')}'
        '${value.second.toString().padLeft(2, '0')}';
  }

  String _excelNumber(num value) {
    return value is int ? value.toString() : value.toStringAsFixed(10);
  }

  static final _crimson = ExcelColor.fromHexString('D92B32');
  static final _carbon = ExcelColor.fromHexString('1D2127');
  static final _graphite = ExcelColor.fromHexString('515A64');
  static final _porcelain = ExcelColor.fromHexString('F7F8FA');
  static final _white = ExcelColor.fromHexString('FFFFFF');
  static final _line = ExcelColor.fromHexString('E4E7EB');

  static final _titleStyle = CellStyle(
    fontFamily: 'Manrope',
    fontSize: 20,
    bold: true,
    fontColorHex: _carbon,
    verticalAlign: VerticalAlign.Center,
  );
  static final _subtitleStyle = CellStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    fontColorHex: _graphite,
    verticalAlign: VerticalAlign.Center,
  );
  static final _headerStyle = CellStyle(
    fontFamily: 'Manrope',
    fontSize: 10,
    bold: true,
    fontColorHex: _white,
    backgroundColorHex: _crimson,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
  );
  static final _bodyStyle = CellStyle(
    fontFamily: 'Manrope',
    fontSize: 10,
    fontColorHex: _carbon,
    backgroundColorHex: _white,
    verticalAlign: VerticalAlign.Center,
    bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: _line),
  );
  static final _alternateStyle = _bodyStyle.copyWith(
    backgroundColorHexVal: _porcelain,
  );
  static final _centeredStyle = _bodyStyle.copyWith(
    horizontalAlignVal: HorizontalAlign.Center,
  );
  static final _alternateCenteredStyle = _alternateStyle.copyWith(
    horizontalAlignVal: HorizontalAlign.Center,
  );
  static final _summaryLabelStyle = CellStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    bold: true,
    fontColorHex: _white,
    backgroundColorHex: _carbon,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  static final _totalStyle = CellStyle(
    fontFamily: 'Manrope',
    fontSize: 26,
    bold: true,
    fontColorHex: _crimson,
    backgroundColorHex: _porcelain,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    numberFormat: const CustomNumericNumFormat(formatCode: '#,##0'),
  );
  static final _noteStyle = CellStyle(
    fontFamily: 'Manrope',
    fontSize: 9,
    italic: true,
    fontColorHex: _graphite,
  );
}
