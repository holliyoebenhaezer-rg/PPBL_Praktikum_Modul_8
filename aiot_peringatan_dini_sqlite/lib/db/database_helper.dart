import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'aiot_peringatan_dini.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pembacaan_sensor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis_sensor TEXT NOT NULL,
            nilai REAL NOT NULL,
            lokasi_pos TEXT NOT NULL,
            waktu TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> tambahPembacaan(PembacaanSensor data) async {
    final db = await database;
    return db.insert('pembacaan_sensor', data.toMap());
  }

  // READ (terurut dari pembacaan terbaru)
  Future<List<PembacaanSensor>> ambilSemuaPembacaan() async {
    final db = await database;
    final rows = await db.query('pembacaan_sensor', orderBy: 'id DESC');
    return rows.map((r) => PembacaanSensor.fromMap(r)).toList();
  }

  // UPDATE
  Future<int> ubahPembacaan(PembacaanSensor data) async {
    final db = await database;
    return db.update(
      'pembacaan_sensor',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // DELETE
  Future<int> hapusPembacaan(int id) async {
    final db = await database;
    return db.delete(
      'pembacaan_sensor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hitung status siaga global dari pembacaan terbaru per jenis sensor di SQLite
  Future<String> hitungStatusSiagaDariDatabase(
    List<JenisSensorInfo> daftarInfo,
  ) async {
    final semua = await ambilSemuaPembacaan();
    if (semua.isEmpty) return 'Aman';

    // Karena sudah diurutkan id DESC, kemunculan pertama tiap jenis_sensor adalah yang terbaru
    final terbaruPerJenis = <String, PembacaanSensor>{};
    for (final item in semua) {
      terbaruPerJenis.putIfAbsent(item.jenisSensor, () => item);
    }

    int levelTertinggi = 0; // 0: Aman, 1: Waspada, 2: Siaga
    for (final info in daftarInfo) {
      final terbaru = terbaruPerJenis[info.kode];
      if (terbaru == null) continue;
      final status = info.tentukanStatus(terbaru.nilai);
      if (status == 'Siaga') {
        return 'Siaga';
      } else if (status == 'Waspada' && levelTertinggi < 1) {
        levelTertinggi = 1;
      }
    }
    return levelTertinggi == 1 ? 'Waspada' : 'Aman';
  }
}