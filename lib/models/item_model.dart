class ItemModel {
  final int? id;
  final String namaBarang;
  final String lokasi;
  final String? foto;
  final DateTime createdAt;
  final String kategori;
  final bool isFavorite;
  final String? catatan;
  final int viewCount;

  // New Fields
  final String? peminjam;
  final DateTime? tglPinjam;
  final DateTime? tglKembali;
  final DateTime? garansiHabis;
  final DateTime? tglKadaluarsa;
  final String? barcode;

  ItemModel({
    this.id,
    required this.namaBarang,
    required this.lokasi,
    this.foto,
    DateTime? createdAt,
    this.kategori = 'Lainnya',
    this.isFavorite = false,
    this.catatan,
    this.viewCount = 0,
    this.peminjam,
    this.tglPinjam,
    this.tglKembali,
    this.garansiHabis,
    this.tglKadaluarsa,
    this.barcode,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert ItemModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'lokasi': lokasi,
      'foto': foto,
      'created_at': createdAt.toIso8601String(),
      'kategori': kategori,
      'is_favorite': isFavorite ? 1 : 0,
      'catatan': catatan,
      'view_count': viewCount,
      'peminjam': peminjam,
      'tgl_pinjam': tglPinjam?.toIso8601String(),
      'tgl_kembali': tglKembali?.toIso8601String(),
      'garansi_habis': garansiHabis?.toIso8601String(),
      'tgl_kadaluarsa': tglKadaluarsa?.toIso8601String(),
      'barcode': barcode,
    };
  }

  // Create ItemModel from Map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int?,
      namaBarang: map['nama_barang'] as String,
      lokasi: map['lokasi'] as String,
      foto: map['foto'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      kategori: map['kategori'] as String? ?? 'Lainnya',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      catatan: map['catatan'] as String?,
      viewCount: map['view_count'] as int? ?? 0,
      peminjam: map['peminjam'] as String?,
      tglPinjam: map['tgl_pinjam'] != null ? DateTime.parse(map['tgl_pinjam'] as String) : null,
      tglKembali: map['tgl_kembali'] != null ? DateTime.parse(map['tgl_kembali'] as String) : null,
      garansiHabis: map['garansi_habis'] != null ? DateTime.parse(map['garansi_habis'] as String) : null,
      tglKadaluarsa: map['tgl_kadaluarsa'] != null ? DateTime.parse(map['tgl_kadaluarsa'] as String) : null,
      barcode: map['barcode'] as String?,
    );
  }

  // Copy with method for updates
  ItemModel copyWith({
    int? id,
    String? namaBarang,
    String? lokasi,
    String? foto,
    DateTime? createdAt,
    String? kategori,
    bool? isFavorite,
    String? catatan,
    int? viewCount,
    String? peminjam,
    DateTime? tglPinjam,
    DateTime? tglKembali,
    DateTime? garansiHabis,
    DateTime? tglKadaluarsa,
    String? barcode,
  }) {
    return ItemModel(
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      lokasi: lokasi ?? this.lokasi,
      foto: foto ?? this.foto,
      createdAt: createdAt ?? this.createdAt,
      kategori: kategori ?? this.kategori,
      isFavorite: isFavorite ?? this.isFavorite,
      catatan: catatan ?? this.catatan,
      viewCount: viewCount ?? this.viewCount,
      peminjam: peminjam ?? this.peminjam,
      tglPinjam: tglPinjam ?? this.tglPinjam,
      tglKembali: tglKembali ?? this.tglKembali,
      garansiHabis: garansiHabis ?? this.garansiHabis,
      tglKadaluarsa: tglKadaluarsa ?? this.tglKadaluarsa,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, namaBarang: $namaBarang, lokasi: $lokasi, foto: $foto, createdAt: $createdAt)';
  }
}
