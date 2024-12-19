import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventario.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Crear tabla de productos
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price INTEGER NOT NULL,
        image TEXT
      )
    ''');

    // Crear tabla de categorías
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null; // Asegurarse de que la instancia se reinicie
  }

  // Métodos para la tabla de productos

  /// Obtiene todos los productos de la base de datos.
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }

  /// Inserta un producto en la tabla y retorna el ID del nuevo registro.
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.insert(
      'products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza un producto existente por su ID.
  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina un producto por su ID.
  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para la tabla de categorías

  /// Obtiene todas las categorías de la base de datos.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  /// Inserta una nueva categoría y retorna su ID.
  Future<int> insertCategory(String name) async {
    final db = await instance.database;
    return await db.insert(
      'categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Ignorar duplicados
    );
  }

  /// Elimina una categoría por su ID.
  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
