# Changelog

Semua perubahan penting pada proyek **Barangku Dimana?** didokumentasikan dalam file ini secara rinci untuk menjaga transparansi pengembangan.

Format penulisan didasarkan pada [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), dan proyek ini mengikuti [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.4.0] - 2026-04-16
### "The Zen Mode & Performance Recovery"
Fokus utama pada versi ini adalah kecepatan akses maksimal dan kenyamanan visual tanpa distraksi.

#### ✨ Diperbarui (Zen Mode UI)
- **Extreme Minimalism:** Transformasi total antarmuka menjadi desain *flat* ultra-bersih.
- **Shadow Elimination:** Menghapus semua efek bayangan (*shadow*) pada kartu barang dan tombol untuk mengurangi beban render GPU dan memberikan estetika premium yang tajam.
- **Flat Surface Logic:** Mengganti gradasi warna pada elemen utama dengan warna solid yang dikurasi untuk kejelasan visual maksimal.
- **Border Refinement:** Memperhalus garis tepi (*border*) menjadi lebih tipis (0.5px - 1.0px) untuk kesan elegan dan modern.

#### 🚀 Optimasi Performa
- **Instant Response Architecture:** 
  - Menghapus semua animasi transisi yang menghambat alur kerja (Daftar barang & transisi tombol).
  - Menonaktifkan efek *ripple/splash* pada interaksi kartu untuk respon visual instan.
- **Silky Smooth Theme Switch:** Implementasi `AnimatedTheme` dan perampingan layer animasi untuk memastikan perpindahan Mode Gelap terasa sangat ringan tanpa *lag*.
- **Battery & GPU Saver:** Optimasi penggunaan daya dengan meminimalisir proses render berulang (*overdraw*).

#### 🛠️ Teknis
- **Global Version Sync:** Sinkronisasi versi aplikasi menjadi 1.4.0 di seluruh komponen sistem (Gradle, Settings, Home, Splash).
- **Branding Update:** Memperbarui tanda air (*watermark*) sistem di Beranda dan Pengaturan menjadi **NEVERLAND STUDIO**.

---

## [1.3.0] - 2026-04-14
### "Quiet Luxury & Visual Branding"
Membangun identitas visual yang unik dan mewah.

#### ✨ Ditambahkan
- **Interactive About Sheet:** Menambahkan *bottom sheet* interaktif yang elegan untuk bagian "Tentang Aplikasi".
- **Neverland Studio Branding:** Integrasi identitas studio ke dalam ekosistem aplikasi.
- **Developer GitHub Integration:** Menghubungkan profil developer langsung ke GitHub melalui menu pengaturan.

#### 🎨 Desain
- **Premium Gradient Icons:** Penggunaan `ShaderMask` untuk memberikan gradasi warna *Emerald-to-Cyan* pada ikon navigasi yang aktif.
- **Quiet Luxury Aesthetic:** Penggunaan warna *Midnight Blue* dan *Pearl White* yang lebih lembut dan eksklusif.
- **Typography Overhaul:** Penyesuaian `letter-spacing` dan `font-weight` untuk meningkatkan keterbacaan teks watermark dan judul.

---

## [1.2.0] - 2026-04-07
### "Insights & Reporting Intelligence"
Memperluas fungsi aplikasi dari sekadar pencatatan menjadi sistem pelaporan.

#### ✨ Ditambahkan
- **Insights Dashboard:** Ringkasan statistik (Total Barang, Barang Favorit, Kategori Teratas) di layar utama.
- **Expansion Categories:** Menambahkan 5 kategori baru yang dikurasi (Dapur, Kantor, Koleksi, Olahraga, Perhiasan).
- **QR & Barcode Toolbox:** Menambahkan shortcut pemindaian cepat di bilah pencarian.
- **Professional PDF Export:** Fitur cetak laporan inventaris format A4 yang rapi untuk keperluan dokumentasi fisik.

#### 🛠️ Optimasi
- **HP Kentang Friendly V1:** 
  - Menghapus efek `BackdropFilter` (Blur) yang memberatkan perangkat spesifikasi rendah.
  - Menyederhanakan kompleksitas bayangan di seluruh aplikasi.
- **Modern Symbols:** Mengganti semua emoji dengan Ikon Outline (`Material Symbols`) yang konsisten.

---

## [1.1.0] - 2026-04-01
### "Efficiency & Personalization"
Memprioritaskan kenyamanan penggunaan jangka panjang.

#### ✨ Ditambahkan
- **True Dark Mode:** Implementasi tema gelap yang dioptimalkan untuk layar OLED.
- **Smart Search:** Fitur pencarian *real-time* dengan filter kategori yang lebih responsif.
- **Favorites System:** Kemampuan untuk menandai barang penting agar mudah diakses di tab khusus.
- **Haptic Feedback:** Integrasi getaran halus saat melakukan aksi penting (Tambah/Hapus/Cari).

---

## [1.0.0] - 2024-04-04
### "The Foundation"
Rilis awal aplikasi Barangku Dimana?

#### ✨ Fitur Inti
- **Core CRUD:** Sistem Manajemen Barang (Tambah, Edit, Hapus foto dan detail).
- **Location Tracker:** Pencatatan lokasi penyimpanan barang secara spesifik.
- **Local Persistence:** Integrasi database `SQLite` untuk penyimpanan data offline yang aman.
- **Cyber Emerald Theme:** Pengenalan aksen warna hijau emerald sebagai identitas awal.
- **Basic Export:** Dukungan ekspor format CSV dasar.

---

*Terakhir diperbarui: 16 April 2026 oleh Neverland Studio*
