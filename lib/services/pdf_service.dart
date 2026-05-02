import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';

class PdfService {
  static Future<void> generateItemReport(List<ItemModel> items) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(dateStr),
            pw.SizedBox(height: 32),
            _buildSummary(items),
            pw.SizedBox(height: 32),
            _buildItemTable(items),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Laporan_Barang_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildHeader(String date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'BARANGKU DIMANA?',
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal700,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Laporan Daftar Inventaris Barang',
              style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: pw.BoxDecoration(
            color: PdfColors.teal50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Tanggal Cetak', style: pw.TextStyle(fontSize: 10, color: PdfColors.teal700, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(date, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(List<ItemModel> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Barang', items.length.toString(), PdfColors.teal700),
          _buildSummaryItem('Kategori Unik', items.map((e) => e.kategori).toSet().length.toString(), PdfColors.orange700),
          _buildSummaryItem('Barang Favorit', items.where((e) => e.isFavorite).length.toString(), PdfColors.amber700),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: color)),
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
          items[index].catatan?.isNotEmpty == true ? items[index].catatan! : '-',
        ],
      ),
      headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.teal700,
        borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(6)),
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 1)),
      ),
      cellStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      cellHeight: 35,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
      },
    );
  }

  static Future<void> generateItemLabels(List<ItemModel> items) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('LABEL BARANG - BARANGKU DIMANA?', 
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.teal700)),
                  pw.Text('Total: ${items.length} Label', 
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.GridView(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              children: items.map((item) => _buildLabel(item)).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Label_Barang_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildLabel(ItemModel item) {
    // Data for QR: prioritize barcode, then fallback to BDM-[ID]
    final qrData = item.barcode?.isNotEmpty == true 
        ? item.barcode! 
        : 'BDM-ID-${item.id ?? item.namaBarang.hashCode}';

    return pw.Container(
      margin: const pw.EdgeInsets.all(5),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            item.namaBarang.toUpperCase(),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            item.lokasi,
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
          pw.Spacer(),
          pw.Container(
            height: 60,
            width: 60,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              drawText: false,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            'BARANGKU DIMANA?',
            style: const pw.TextStyle(fontSize: 5, color: PdfColors.grey400, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey300, thickness: 1),
        pw.SizedBox(height: 12),
        pw.Text(
          'Dibuat secara otomatis oleh Aplikasi Barangku Dimana?',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '© ${DateTime.now().year} Neverland Studio. Hak Cipta Dilindungi.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
        ),
      ],
    );
  }
}
