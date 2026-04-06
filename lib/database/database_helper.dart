import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('barangku_dimana.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER DEFAULT 0';

    await db.execute('''
      CREATE TABLE items (
        id $idType,
        nama_barang $textType,
        lokasi $textType,
        foto $textTypeNullable,
        created_at $textType,
        kategori TEXT DEFAULT 'Lainnya',
        is_favorite $intType,
        catatan $textTypeNullable,
        view_count $intType,
        peminjam $textTypeNullable,
        tgl_pinjam $textTypeNullable,
        tgl_kembali $textTypeNullable,
        garansi_habis $textTypeNullable,
        tgl_kadaluarsa $textTypeNullable,
        barcode $textTypeNullable
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate from v1 to v2
      await db.execute('ALTER TABLE items ADD COLUMN kategori TEXT DEFAULT "Lainnya"');
      await db.execute('ALTER TABLE items ADD COLUMN is_favorite INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE items ADD COLUMN catatan TEXT');
      await db.execute('ALTER TABLE items ADD COLUMN view_count INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      // Migrate from v2 to v3
      await db.execute('ALTER TABLE items ADD COLUMN peminjam TEXT');
      await db.execute('ALTER TABLE items ADD COLUMN tgl_pinjam TEXT');
      await db.execute('ALTER TABLE items ADD COLUMN tgl_kembali TEXT');
      await db.execute('ALTER TABLE items ADD COLUMN garansi_habis TEXT');
      await db.execute('ALTER TABLE items ADD COLUMN tgl_kadaluarsa TEXT');
      await db.execute('ALTER TABLE items ADD COLUMN barcode TEXT');
    }
  }

  // Create - Insert new item
  Future<int> insertItem(ItemModel item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  // Read - Get all items
  Future<List<ItemModel>> getAllItems() async {
    final db = await database;
    const orderBy = 'created_at DESC';
    final result = await db.query('items', orderBy: orderBy);

    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // Read - Get single item by ID
  Future<ItemModel?> getItem(int id) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ItemModel.fromMap(maps.first);
    }
    return null;
  }

  // Read - Search items by name (case insensitive)
  Future<List<ItemModel>> searchItems(String query) async {
    final db = await database;
    final result = await db.query(
      'items',
      where: 'LOWER(nama_barang) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // Update - Update existing item
  Future<int> updateItem(ItemModel item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete - Remove item by ID
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all items (for testing)
  Future<int> deleteAllItems() async {
    final db = await database;
    return await db.delete('items');
  }

  // Toggle favorite status
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'items',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get favorite items only
  Future<List<ItemModel>> getFavoriteItems() async {
    final db = await database;
    final result = await db.query(
      'items',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // Get items by category
  Future<List<ItemModel>> getItemsByCategory(String kategori) async {
    final db = await database;
    final result = await db.query(
      'items',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // Increment view count
  Future<void> incrementViewCount(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE items SET view_count = view_count + 1 WHERE id = ?',
      [id],
    );
  }

  // Get most viewed items
  Future<List<ItemModel>> getMostViewedItems({int limit = 10}) async {
    final db = await database;
    final result = await db.query(
      'items',
      orderBy: 'view_count DESC',
      limit: limit,
    );
    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // Get statistics
  Future<Map<String, int>> getCategoryStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT kategori, COUNT(*) as count 
      FROM items 
      GROUP BY kategori
    ''');
    
    Map<String, int> stats = {};
    for (var row in result) {
      stats[row['kategori'] as String] = row['count'] as int;
    }
    return stats;
  }

  // Get all unique locations for autocomplete
  Future<List<String>> getAllLocations() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT lokasi 
      FROM items 
      ORDER BY lokasi ASC
    ''');
    return result.map((row) => row['lokasi'] as String).toList();
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
