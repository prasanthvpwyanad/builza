import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/money.dart';
import '../../data/models/cashbook_entry.dart';
import 'report_math.dart';

String _inr(int amount) => formatInr(amount).replaceFirst('₹', 'INR');

Future<Uint8List> buildCompanyStatementPdf({
  required String companyName,
  required List<CashbookEntry> entries,
}) async {
  final pdf = pw.Document();
  final overall = totalsOf(entries);
  final projects = totalsByProject(entries);
  final categories = paidByCategory(entries);
  final sorted = sortedEntries(entries);
  final generated = DateFormat('d MMM yyyy, h:mm a').format(DateTime.now());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BUILZA', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
          pw.SizedBox(height: 4),
          pw.Text(companyName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text('Cashbook statement  •  Generated $generated', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 8),
          pw.Divider(),
        ],
      ),
      build: (context) => [
        pw.SizedBox(height: 8),
        pw.Text('Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const ['Received', 'Paid', 'Balance', 'Entries'],
          data: [
            [_inr(overall.received), _inr(overall.paid), _inr(overall.balance), '${entries.length}'],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF102D50)),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 18),
        pw.Text('Project-wise', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const ['Project', 'Received', 'Paid', 'Balance'],
          data: projects.entries
              .map((item) => [item.key, _inr(item.value.received), _inr(item.value.paid), _inr(item.value.balance)])
              .toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1677D2)),
          cellStyle: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 18),
        pw.Text('Paid by category', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const ['Category', 'Paid'],
          data: categories.entries.map((item) => [item.key, _inr(item.value)]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1677D2)),
          cellStyle: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 18),
        pw.Text('Entries', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (sorted.isEmpty)
          pw.Text('No cashbook entries.')
        else
          pw.TableHelper.fromTextArray(
            headers: const ['Date', 'Type', 'Project', 'Details', 'Amount'],
            data: sorted.take(80).map((entry) {
              final date = entry.createdAt == null ? '-' : DateFormat('d MMM yyyy').format(entry.createdAt!);
              return [
                date,
                entry.isPaid ? 'Paid' : 'Received',
                entry.projectName,
                entry.title,
                _inr(entry.amount),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF102D50)),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
            },
          ),
      ],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}  •  Isolated company records',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ),
    ),
  );

  return pdf.save();
}
