import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;

  DBHelper._();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ship.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 船表
    await db.execute('''
      CREATE TABLE ship_air (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        level1 INTEGER,
        level100 INTEGER,
        level120 INTEGER,
        level125 INTEGER,
        star1 INTEGER,
        star2 INTEGER,
        star3 INTEGER,
        slot1_type TEXT,
        slot1_count INTEGER,
        slot2_type TEXT,
        slot2_count INTEGER,
        slot3_type TEXT,
        slot3_count INTEGER,
        reload INTEGER,
        favor TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ship_battle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        level1 INTEGER,
        level100 INTEGER,
        level120 INTEGER,
        level125 INTEGER,
        star1 INTEGER,
        star2 INTEGER,
        star3 INTEGER,
        slot1_type TEXT,
        slot1_count INTEGER,
        slot2_type TEXT,
        slot2_count INTEGER,
        slot3_type TEXT,
        slot3_count INTEGER,
        reload INTEGER,
        favor TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ship_airbattle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        level1 INTEGER,
        level100 INTEGER,
        level120 INTEGER,
        level125 INTEGER,
        star1 INTEGER,
        star2 INTEGER,
        star3 INTEGER,
        slot1_type TEXT,
        slot1_count INTEGER,
        slot2_type TEXT,
        slot2_count INTEGER,
        slot3_type TEXT,
        slot3_count INTEGER,
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
        cd_time REAL
      )
    ''');

    // 主炮表
    await db.execute('''
      CREATE TABLE gun (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        cd_time REAL
      )
    ''');

    // Buff 表
    await db.execute('''
      CREATE TABLE buff (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        value REAL
      )
    ''');

    // Cat 表
    await db.execute('''
      CREATE TABLE cat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        cd_reduce REAL,
        reload_increase REAL
      )
    ''');

    // 插入示例数据
    await db.insert('ship_air', {
      'name': 'A',
      'level1': 1,
      'level100': 100,
      'level120': 120,
      'level125': 125,
      'star1': 1,
      'star2': 2,
      'star3': 3,
      'slot1_type': '战斗机',
      'slot1_count': 2,
      'slot2_type': '鱼雷机',
      'slot2_count': 2,
      'slot3_type': '轰炸机',
      'slot3_count': 2,
      'reload': 100,
      'favor': '爱'
    });

    await db.insert('plane', {'name': '战斗机A', 'type': '战斗机', 'cd_time': 10.5});
    await db.insert('plane', {'name': '鱼雷机B', 'type': '鱼雷机', 'cd_time': 18.1});
    await db.insert('plane', {'name': '轰炸机C', 'type': '轰炸机', 'cd_time': 15.0});

    await db.insert('gun', {'name': '高爆弹A', 'type': '高爆弹', 'cd_time': 20.0});

    await db.insert('buff', {'name': '首轮CD减', 'type': 'cd', 'value': 5});
    await db.insert('buff', {'name': '装填增加', 'type': 'reload', 'value': 10});

    await db.insert('cat', {'name': '猫A', 'cd_reduce': 2, 'reload_increase': 5});
  }

  Future<List<Map<String, dynamic>>> getTable(String table) async {
    final db = await database;
    return await db.query(table);
  }
}
