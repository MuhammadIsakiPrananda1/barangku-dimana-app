class AIService {
  static const Map<String, List<String>> _categoryKeywords = {
    'Elektronik': [
      'hp', 'handphone', 'laptop', 'charger', 'kabel', 'mouse', 'keyboard', 
      'monitor', 'televisi', 'tv', 'remote', 'baterai', 'powerbank', 'kamera',
      'headset', 'earphone', 'speaker'
    ],
    'Kunci': [
      'kunci', 'gembok', 'key', 'cadangan', 'pintu', 'motor', 'mobil', 'rumah'
    ],
    'Dokumen': [
      'ijazah', 'paspor', 'ktp', 'sim', 'stnk', 'buku nikah', 'akta', 'kartu',
      'surat', 'sertifikat', 'dokumen', 'berkas', 'polis', 'kwitansi'
    ],
    'Pakaian': [
      'baju', 'kaos', 'celana', 'jaket', 'rok', 'gamis', 'kerudung', 'topi',
      'sepatu', 'sandal', 'tas', 'dompet', 'sabuk', 'jas', 'seragam'
    ],
    'Alat': [
      'palu', 'obeng', 'tang', 'bor', 'gergaji', 'kunci inggris', 'meteran',
      'lem', 'lakban', 'cat', 'kuas', 'perkakas', 'baut', 'paku'
    ],
    'Obat': [
      'obat', 'paracetamol', 'vitamin', 'suplemen', 'p3k', 'perban', 'betadine',
      'masker', 'termometer', 'salep', 'sirup', 'kapsul', 'tablet'
    ],
    'Mainan': [
      'mainan', 'boneka', 'lego', 'puzzle', 'kartu', 'board game', 'robot',
      'mobil-mobilan', 'drone', 'konsol', 'stik', 'bola'
    ],
    'Buku': [
      'buku', 'novel', 'komik', 'majalah', 'jurnal', 'atlas', 'kamus',
      'ensiklopedia', 'materi', 'catatan'
    ],
    'Dapur': [
      'piring', 'gelas', 'sendok', 'garpu', 'pisau', 'panci', 'wajan', 'teko',
      'kompor', 'blender', 'mixer', 'rice cooker', 'oven', 'wadah'
    ],
    'Kantor': [
      'pena', 'pulpen', 'pensil', 'penghapus', 'penggaris', 'stapler', 'kertas',
      'tinta', 'printer', 'scanner', 'folder', 'map', 'amplop'
    ],
    'Olahraga': [
      'raket', 'bola', 'sepeda', 'helm', 'tali skipping', 'matras', 'dumbel',
      'jersey', 'kacamata renang', 'pancing', 'tendah'
    ],
    'Perhiasan': [
      'cincin', 'kalung', 'gelang', 'anting', 'jam tangan', 'emas', 'perak'
    ],
  };

  static String predictCategory(String itemName) {
    if (itemName.isEmpty) return 'Lainnya';
    
    final lowerName = itemName.toLowerCase();
    
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerName.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return 'Lainnya';
  }

  static String suggestLocation(String category) {
    switch (category) {
      case 'Elektronik': return 'Laci Elektronik / Meja Kerja';
      case 'Kunci': return 'Gantungan Kunci / Kotak Pintu';
      case 'Dokumen': return 'Map Berkas / Brankas';
      case 'Pakaian': return 'Lemari Pakaian / Kotak Aksesoris';
      case 'Alat': return 'Kotak Perkakas / Gudang';
      case 'Obat': return 'Kotak P3K / Lemari Obat';
      case 'Buku': return 'Rak Buku / Meja Belajar';
      case 'Dapur': return 'Lemari Dapur / Rak Piring';
      default: return 'Laci Utama / Kotak Penyimpanan';
    }
  }
}
