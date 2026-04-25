import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> faqs = [
      {
        'question': 'Bagaimana cara mendaftarkan barang baru?',
        'answer':
            'Pergi ke Beranda, lalu tekan tombol ikon Plus (+) besar berwarna hijau di kanan bawah layar Anda. Isi nama, kategori, dan lokasi barang.'
      },
      {
        'question': 'Apakah data & gamber barang saya tersimpan di internet?',
        'answer':
            'Tidak. Untuk privasi, semua foto dan rekaman barang Anda tersimpan murni secara offline (lokal) di penyimpanan HP Anda.'
      },
      {
        'question': 'Tujuan fitur Alarm Kadaluarsa & Garansi?',
        'answer':
            'Fitur tersebut dapat memunculkan notifikasi otomatis di Notifikasi HP Anda ketika sebuah barang Anda hampir kadaluarsa atau garansinya hampir seminggu lagi berakhir. Aktifkan dari menu Beranda dengan menambah tanggal tersebut pada produk.'
      },
      {
        'question': 'Bagaimana menggunakan tab "Lokasi"?',
        'answer':
            'Tab "Lokasi" akan secara unik mengelompokkan semua barang Anda berdasarkan nama lokasinya (misal: "Laci Pojok", "Meja Setrika"). Jika Anda butuh tahu isi sebuah kotak, Anda hanya perlu mengetuk nama lokasi itu untuk melihat semua isinya.'
      },
      {
        'question': 'Apa gunanya Kunci PIN Aplikasi?',
        'answer':
            'Jika ponsel Anda sering dipinjam saudara atau teman dan Anda ragu mereka mengacak-acak catatan data barang Anda, fitur Kunci PIN ini menjegal siapapun tanpa kode 4 digit agar tidak bisa melihat koleksi properti pribadi Anda.'
      },
      {
        'question': 'Bagaimana mengekspor data laporan?',
        'answer':
            'Anda dapat menuju Pengaturan > Data & Laporan > Ekspor Data ke PDF. Data akan dicetak dalam format rapi yang bisa langsung Anda kirim via Whatsapp atau dicetak ke Printer.'
      },
      {
        'question': 'Bagaimana bila saya lupa PIN aplikasi?',
        'answer':
            'Pada versi saat ini, lupa PIN mengharuskan Anda melakukan Hapus Data Aplikasi sepenuhnya dari pengaturan Android/iOS Anda, mengingat fitur privasinya dirancang tanpa akses pintu belakang internet pusat. Mohon jangan sampai hilang PIN tersebut!'
      },
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDark ? Colors.white : AppTheme.slate900),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : AppTheme.slate900,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: isDark
                  ? AppTheme.slate800.withValues(alpha: 0.5)
                  : Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: (isDark ? Colors.white : AppTheme.slate900)
                      .withValues(alpha: 0.05),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                iconColor: AppTheme.emerald,
                collapsedIconColor: AppTheme.slate400,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minTileHeight: 48,
                title: Text(
                  faq['question']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.slate900,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    faq['answer']!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * index))
              .slideX();
        },
      ),
    );
  }
}
