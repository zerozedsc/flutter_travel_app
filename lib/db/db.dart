import '../back_end/configs.dart';
import '../back_end/service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

export 'package:sqflite/sqflite.dart';

// ignore: non_constant_identifier_names
late Database DB;
late Database userDB;
late List<String> existPrefList;

// このクラスは sqlite3 .db データベースに接続するために使用される。
// アプリの初期化時にmainで呼び出され、「Database 」のデータがDB (late Database DB;) に保存される。
class DatabaseConnection {
  static int _dbVersion = 1;

  static Future<Database> getDatabase({required String dbName}) async {
    // Initialize and store the database if not already cached
    final db = await _initDB(dbName);
    return db;
  }

  static Future<Database> _initDB(String dbName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, dbName);

    // Path to the database in assets
    String assetsDbPath = 'assets/db/$dbName';

    // Check if the database already exists in the writable directory
    if (FileSystemEntity.typeSync(dbPath) == FileSystemEntityType.notFound) {
      // Copy the database from assets to the documents directory
      print("Database not found in writable directory. Copying from assets...");
      ByteData data = await rootBundle.load(assetsDbPath);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
      print("Database copied to writable directory.");
    } else {
      // Check if the assets database has been updated
      ByteData assetData = await rootBundle.load(assetsDbPath);
      List<int> assetBytes = assetData.buffer
          .asUint8List(assetData.offsetInBytes, assetData.lengthInBytes);

      List<int> writableBytes = await File(dbPath).readAsBytes();

      // Compare the bytes to determine if an update is needed
      if (!_compareBytes(assetBytes, writableBytes)) {
        print(
            "Database in assets has been updated. Replacing the writable database...");
        await File(dbPath).writeAsBytes(assetBytes);
        print("Database updated successfully.");
      } else {
        print("Database in writable directory is up to date.");
      }
    }

    // Open the database
    return await openDatabase(dbPath, version: _dbVersion ?? 1);
  }

  /// Helper function to compare two byte arrays
  static bool _compareBytes(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

// 接続が確立された後にデータベースからデータを照会するために使用する。
// 呼び方例: DatabaseQuery　dbQuery = new　DatabaseQuery(db: DB);
class DatabaseQuery {
  const DatabaseQuery({required this.db});
  final Database db;

  Future<List<Map<String, dynamic>>> query(
    String query,
  ) async {
    return db.rawQuery(query);
  }

  Future<void> printOneInTable(String tableName) async {
    try {
      final data = await db.query(tableName);
      print(data[0]);
    } catch (e) {
      print('An error occurred while shows data from $tableName: $e');
    }
  }

  Future<void> printAllInTable(String tableName) async {
    try {
      final data = await db.query(tableName);
      for (var row in data) {
        print(row); // Process each row as needed
      }
    } catch (e) {
      print('An error occurred while shows data from $tableName: $e');
    }
  }

  // Function to get a random row from the table
  Future<Map<String, dynamic>?> getRandomRow(String tableName) async {
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      orderBy: 'RANDOM()',
      limit: 1,
    );

    // Return the first (and only) result, or null if the table is empty
    return result.isNotEmpty ? result.first : null;
  }

  // Function to get multiple random rows from the table
  Future<List<Map<String, dynamic>>> getRandomRows(
      String tableName, int count) async {
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      orderBy: 'RANDOM()',
      limit: count,
    );

    return result;
  }

// データの挿入
  Future<void> insertData(tableName, Map<String, dynamic> data) async {
    try {
      await db.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // error-handling
      print('An error occurred while inserting data: $e');
    }
  }

// データの取得 my_table全ての取得
  Future<List<Map<String, dynamic>>> fetchAllData(tableName) async {
    try {
      return await db.query(tableName);
    } catch (e) {
      // error-handling
      print('An error occurred while fetching data: $e');
      return [];
    }
  }

// データの更新 特定のidを持つ行の更新
  Future<void> updateData(tableName, id, Map<String, dynamic> newData) async {
    try {
      await db.update(
        tableName,
        newData,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // error-handling
      print('An error occurred while updating data: $e');
    }
  }

// データの削除 指定したidを持つ行を削除
  Future<void> deleteData(tableName, id) async {
    try {
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // error-handling
      print('An error occurred while deleting data: $e');
    }
  }
}
