import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'ship_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // 舰船分类
    await db.execute('''
      CREATE TABLE type_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    // 舰船 - 航空
    await db.execute('''
      CREATE TABLE ship_air (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        level INTEGER,
        star INTEGER,
        plane1 TEXT,
        plane2 TEXT,
        plane3 TEXT,
        main_gun TEXT,
        reload INTEGER,
        favor TEXT
      )
    ''');

    // 舰船 - 炮击
    await db.execute('''
      CREATE TABLE ship_battle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        level INTEGER,
        star INTEGER,
        main_gun TEXT,
        reload INTEGER,
        favor TEXT
      )
    ''');

    // 舰船 - 航战
    await db.execute('''
      CREATE TABLE ship_air_battle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        level INTEGER,
        star INTEGER,
        plane1 TEXT,
        plane2 TEXT,
        main_gun TEXT,
        reload INTEGER,
        favor TEXT
      )
    ''');

    // 舰载机表
    await db.execute('''
      CREATE TABLE plane (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        cd REAL
      )
    ''');

    // 主炮表
    await db.execute('''
      CREATE TABLE main_gun (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        cd REAL
      )
    ''');
  }

  // 获取表数据
  Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await database;
    return await db.query(table);
  }
}
