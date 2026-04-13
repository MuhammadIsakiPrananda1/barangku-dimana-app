import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';

class PdfService {
  static Future<void> generateItemReport(List<ItemModel> items) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(dateStr),
            pw.SizedBox(height: 24),
            _buildSummary(items),
            pw.SizedBox(height: 24),
            _buildItemTable(items),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Barang_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildHeader(String date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'BARANGKU DIMANA?',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal,
              ),
            ),
            pw.Text(
              'Laporan Daftar Inventaris Barang',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Diterbitkan pada:'),
            pw.Text(date, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(List<ItemModel> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Barang', items.length.toString()),
          _buildSummaryItem('Kategori Unik', items.map((e) => e.kategori).toSet().length.toString()),
          _buildSummaryItem('Favorit', items.where((e) => e.isFavorite).length.toString()),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
      ],
    );
  }

  static pw.Widget _buildItemTable(List<ItemModel> items) {
    final headers = ['No', 'Nama Barang', 'Lokasi', 'Kategori', 'Catatan'];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: List<List<String>>.generate(
        items.length,
        (index) => [
          (index + 1).toString(),
          items[index].namaBarang,
          items[index].lokasi,
          items[index].kategori,
          items[index].catatan ?? '-',
        ],
      ),
      headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Text(
          'Dibuat secara otomatis oleh Aplikasi Barangku Dimana? - Neverland Studio',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
