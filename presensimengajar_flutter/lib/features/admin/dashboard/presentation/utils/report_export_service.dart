import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ReportExportService {
  static Future<void> exportToCsv(
    List<Map<String, dynamic>> data,
    int month,
    int year,
  ) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Laporan Presensi Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(year, month))}',
    ]);
    rows.add([]);
    rows.add([
      'NIP',
      'Nama Guru',
      'Hadir',
      'Telat',
      'Izin/Sakit/Cuti',
      'Alpha',
      'Total Kehadiran',
    ]);

    // Data
    for (final row in data) {
      rows.add([
        row['teacherNip'],
        row['teacherName'],
        row['present'],
        row['late'],
        row['permit'],
        row['alpha'],
        row['totalAttendance'],
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/laporan_presensi_${month}_$year.csv');
    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(file.path)], text: 'Laporan Presensi CSV');
  }

  static Future<void> exportToPdf(
    List<Map<String, dynamic>> data,
    int month,
    int year,
  ) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Laporan Presensi Guru',
                style: pw.TextStyle(
                  fontSize: 24,
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Paragraph(
              text:
                  'Periode: ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(year, month))}',
              style: pw.TextStyle(fontSize: 14, font: font),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'NIP',
                'Nama',
                'Hadir',
                'Telat',
                'Izin',
                'Alpha',
                'Total',
              ],
              data: data.map((row) {
                return [
                  row['teacherNip'],
                  row['teacherName'],
                  row['present'],
                  row['late'],
                  row['permit'],
                  row['alpha'],
                  row['totalAttendance'],
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
              cellStyle: pw.TextStyle(font: font, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'laporan_presensi_${month}_$year.pdf',
    );
  }
}
