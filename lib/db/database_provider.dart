import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../models/employee.dart';

class DatabaseProvider {
  static const String TABLE_EMPLOYEES = "employees";
  static const String COLUMN_ID = "id";
  static const String COLUMN_FIRST_NAME = "first_name";
  static const String COLUMN_LAST_NAME = "last_name";
  static const String COLUMN_COLOR = "color";
  static const String COLUMN_HOURS = "hours";
  static const String COLUMN_SHIFTS = "shifts";

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await createDatabase();

    return _database;
  }

  Future<Database> createDatabase() async {
    final String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, "employees.db"),
      version: 3,
      onCreate: (Database database, int version) async {
        print("Creating emp table");
        await database.execute("CREATE TABLE $TABLE_EMPLOYEES ("
            "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_FIRST_NAME TEXT NOT NULL,"
            "$COLUMN_LAST_NAME TEXT NOT NULL,"
            "$COLUMN_COLOR INTEGER NOT NULL,"
            "$COLUMN_HOURS REAL DEFAULT 0,"
            "$COLUMN_SHIFTS TEXT);");
      },
    );
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;

    var employees = await db.query(TABLE_EMPLOYEES,
        columns: [
          COLUMN_ID,
          COLUMN_FIRST_NAME,
          COLUMN_LAST_NAME,
          COLUMN_COLOR,
          COLUMN_HOURS,
          COLUMN_SHIFTS
        ],
        orderBy: COLUMN_HOURS);
    List<Employee> empList = List<Employee>();

    employees.forEach((emp) {
      print(emp.values);
      empList.add(Employee.fromMap(emp));
    });

    return empList;
  }

  Future<int> count() async {
    final db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $TABLE_EMPLOYEES"));
  }

  Future<Employee> insertEmployee(Employee emp) async {
    final db = await database;
    emp.id = await db.insert(TABLE_EMPLOYEES, emp.toMap());
    return emp;
  }

  Future<int> updateEmployee(int id, Employee emp) async {
    final db = await database;

    return await db.update(TABLE_EMPLOYEES, emp.toMap(),
        where: "$COLUMN_ID = ?", whereArgs: [id]);
  }

  Future<int> deleteEmployee(int id) async {
    final db = await database;

    return await db
        .delete(TABLE_EMPLOYEES, where: "$COLUMN_ID = ?", whereArgs: [id]);
  }
}
