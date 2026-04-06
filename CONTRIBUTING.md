# Panduan Berkontribusi (Contributing Guidelines)

Terima kasih telah tertarik untuk berkontribusi pada proyek **Aplikasi Barangku Dimana**! Kami sangat menghargai dukungan komunitas untuk membuat aplikasi ini menjadi lebih baik. 🎉

## Cara Berkontribusi

### 1. Melaporkan Bug
Jika Anda menemukan bug, silakan buat _issue_ baru di GitHub. Pastikan untuk mencantumkan:
- Langkah-langkah untuk mereproduksi bug.
- Versi perangkat OS atau Android/iOS.
- Tangkapan layar (screenshot) jika memungkinkan.

### 2. Mengajukan Fitur Baru
Punya ide keren untuk aplikasi ini? Buat _issue_ dengan label `enhancement` agar kita bisa mendiskusikannya terlebih dahulu sebelum Anda mulai menulis kode!

### 3. Mengirimkan Pull Request (PR)
Jika Anda ingin memperbaiki bug atau menambahkan fitur langsung:
1. **Fork** repository ini ke akun GitHub Anda.
2. Buat _branch_ baru dari `main` (contoh: `git checkout -b fitur-keren`).
3. Lakukan perubahan Anda dan pastikan kode yang ditulis rapi.
4. Jangan lupa untuk menguji (test) perubahan yang Anda buat.
5. **Commit** perubahan Anda (contoh: `git commit -m 'feat: menambahkan fitur pencarian dengan suara'`). Sangat disarankan menggunakan [Conventional Commits](https://www.conventionalcommits.org/).
6. **Push** ke branch di repository GitHub Anda (`git push origin fitur-keren`).
7. Buka **Pull Request** ke repository utama.

## Konvensi Penulisan Kode (Code Style)
- Proyek ini menggunakan standar _linting_ Dart & Flutter dasar (`flutter_lints`).
- Pastikan tidak ada _warning_ atau _error_ dari _linter_ dengan menjalankan:
  ```bash
  flutter analyze
  ```
- Gunakan bahasa yang konsisten dalam kode (prioritaskan Bahasa Inggris untuk penamaan variabel, kelas, atau fungsi agar standar. UI tetap dapat menggunakan Bahasa Indonesia).

Mari bangun proyek Open Source berkualitas bersama-sama!
