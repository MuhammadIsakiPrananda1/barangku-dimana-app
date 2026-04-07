# Changelog

Semua perubahan penting pada proyek ini akan didokumentasikan dalam file ini.

Format penulisan didasarkan pada [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
dan proyek ini mengikuti [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-04-07

### Ditambahkan
- **Pusat Wawasan (Insights Dashboard):** Ringkasan statistik (Total, Dipinjam, Status Penting) di layar utama.
- **Wawasan Kategori Baru:** Menambahkan 5 kategori baru (Dapur, Kantor, Koleksi, Olahraga, Perhiasan).
- **Sistem Notifikasi Pintar:** Pengingat garansi dan kadaluarsa dengan peringatan h-7.
- **Ekspor Laporan PDF:** Fitur cetak laporan inventaris format A4 yang profesional.

### Diperbarui
- **Modernisasi UI:** Mengganti semua emoji dengan Ikon Outline (`Material Symbols`) yang elegan dan konsisten.
- **Optimasi Performa ("HP Kentang Friendly"):** 
  - Menghapus efek `BackdropFilter` (Blur) yang berat pada GPU.
  - Menyederhanakan kompleksitas bayangan (*Shadow Blur Radius*) di seluruh kartu.
  - Sederhanakan animasi transisi menjadi lebih ringan namun tetap *smooth*.
- Sinkronisasi versi aplikasi menjadi 1.2.0 di semua bagian (Splash, Home, Gradle).

## [1.0.0] - 2024-04-04

### Ditambahkan

- Inisialisasi proyek Flutter `barangku_dimana`.
- Fitur Manajemen Barang (Tambah, Edit, Hapus).
- Fitur Pelacak Lokasi Barang.
- Statistik barang dengan grafik interaktif.
- Fitur Ekspor Data ke PDF dan CSV.
- Animasi UI menggunakan `flutter_animate`.
- Dukungan Tema Modern (Cyber Emerald).

---

*Terakhir diperbarui: 7 April 2026*
