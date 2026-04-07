import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';

class ReportService {
  static Future<void> generateInventoryPdf(List<ItemModel> items) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Barangku Dimana?',
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 24, color: PdfColors.teal)),
                pw.Text('Laporan Inventaris',
                    style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('Dicetak pada: $dateStr',
                style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
            pw.Divider(thickness: 1, color: PdfColors.grey),
            pw.SizedBox(height: 20),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500),
          ),
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            context: context,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 11),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            headers: ['No', 'Nama Barang', 'Lokasi', 'Kategori', 'Catatan', 'Status'],
            data: List<List<String>>.generate(items.length, (index) {
              final item = items[index];
              String status = '';
              if (item.peminjam != null) status += 'Dipinjam: ${item.peminjam}\n';
              if (item.garansiHabis != null && item.garansiHabis!.isBefore(DateTime.now())) {
                status += 'Garansi Habis';
              }
              return [
                (index + 1).toString(),
                item.namaBarang,
                item.lokasi,
                item.kategori,
                item.catatan ?? '-',
                status.isNotEmpty ? status : 'Tersedia',
              ];
            }),
          ),
          pw.SizedBox(height: 40),
          pw.Text('Statistik Ringkas:', style: pw.TextStyle(font: fontBold, fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Bullet(text: 'Total Barang: ${items.length}', style: pw.TextStyle(font: font, fontSize: 11)),
          pw.Bullet(text: 'Barang Dipinjam: ${items.where((i) => i.peminjam != null).length}', style: pw.TextStyle(font: font, fontSize: 11)),
          pw.Bullet(text: 'Kategori Terbanyak: ${_getMostFrequentCategory(items)}', style: pw.TextStyle(font: font, fontSize: 11)),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Inventaris_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static String _getMostFrequentCategory(List<ItemModel> items) {
    if (items.isEmpty) return '-';
    final map = <String, int>{};
    for (var item in items) {
      map[item.kategori] = (map[item.kategori] ?? 0) + 1;
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}
