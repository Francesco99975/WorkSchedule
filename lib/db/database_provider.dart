import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../providers/department.dart';
import '../providers/employee.dart';

class DatabaseProvider {
  static const String TABLE_EMPLOYEES = "employees";
  static const String COLUMN_ID = "id";
  static const String COLUMN_FIRST_NAME = "first_name";
  static const String COLUMN_LAST_NAME = "last_name";
  static const String COLUMN_COLOR = "color";
  static const String COLUMN_PRIORITY = "prority";
  static const String COLUMN_SHIFTS = "shifts";

  static const String TABLE_SETTINGS = "settings";
  static const String COLUMN_H24 = 'H24';

  static const String TABLE_DEPARTMENTS = "departments";
  static const String COLUMN_DEPT_ID = "dept_id";
  static const String COLUMN_DEPT_NAME = "dept_name";

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
      version: 7,
      onCreate: (Database database, int version) async {
        print("Creating emp table");
        await database.execute("CREATE TABLE IF NOT EXISTS $TABLE_DEPARTMENTS ("
            "$COLUMN_DEPT_ID INTEGER PRIMARY KEY,"
            "$COLUMN_DEPT_NAME TEXT NOT NULL);");
        await database.insert(TABLE_DEPARTMENTS, {COLUMN_DEPT_NAME: 'Default'});
        await database.execute("CREATE TABLE IF NOT EXISTS $TABLE_EMPLOYEES ("
            "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_FIRST_NAME TEXT NOT NULL,"
            "$COLUMN_LAST_NAME TEXT NOT NULL,"
            "$COLUMN_COLOR INTEGER NOT NULL,"
            "$COLUMN_PRIORITY REAL DEFAULT 0,"
            "$COLUMN_SHIFTS TEXT,"
            "$COLUMN_DEPT_ID INTEGER,"
            "FOREIGN KEY($COLUMN_DEPT_ID) REFERENCES $TABLE_DEPARTMENTS($COLUMN_DEPT_ID));");
        await database.execute("PRAGMA foreign_keys = ON;");
        await database.execute("CREATE TABLE IF NOT EXISTS $TABLE_SETTINGS ("
            "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_H24 INTEGER DEFAULT 0);");
        await database.insert(TABLE_SETTINGS, {COLUMN_H24: 0});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          print("Updating DB");
          await db.execute(
              "ALTER TABLE $TABLE_EMPLOYEES RENAME COLUMN hours TO $COLUMN_PRIORITY;");
          await db.execute("CREATE TABLE IF NOT EXISTS $TABLE_SETTINGS ("
              "$COLUMN_ID INTEGER PRIMARY KEY,"
              "$COLUMN_H24 INTEGER DEFAULT 0);");
          await db.insert(TABLE_SETTINGS, {COLUMN_H24: 0});
          await db.execute("CREATE TABLE IF NOT EXISTS $TABLE_DEPARTMENTS ("
              "$COLUMN_DEPT_ID INTEGER PRIMARY KEY,"
              "$COLUMN_DEPT_NAME TEXT NOT NULL);");
          await db.insert(TABLE_DEPARTMENTS, {COLUMN_DEPT_NAME: 'Default'});
          await db.execute("PRAGMA foreign_keys = OFF;");
          await db.execute("BEGIN TRANSACTION;");
          await db.execute("CREATE TABLE tmp("
              "$COLUMN_ID INTEGER PRIMARY KEY,"
              "$COLUMN_FIRST_NAME TEXT NOT NULL,"
              "$COLUMN_LAST_NAME TEXT NOT NULL,"
              "$COLUMN_COLOR INTEGER NOT NULL,"
              "$COLUMN_PRIORITY REAL DEFAULT 0,"
              "$COLUMN_SHIFTS TEXT,"
              "$COLUMN_DEPT_ID INTEGER,"
              "FOREIGN KEY($COLUMN_DEPT_ID) REFERENCES $TABLE_DEPARTMENTS($COLUMN_DEPT_ID));");
          await db.execute(
              "INSERT INTO tmp VALUES((SELECT $COLUMN_ID FROM $TABLE_EMPLOYEES),"
              "(SELECT $COLUMN_FIRST_NAME FROM $TABLE_EMPLOYEES),"
              "(SELECT $COLUMN_LAST_NAME FROM $TABLE_EMPLOYEES),"
              "(SELECT $COLUMN_COLOR FROM $TABLE_EMPLOYEES),"
              "(SELECT $COLUMN_PRIORITY FROM $TABLE_EMPLOYEES),"
              "(SELECT $COLUMN_SHIFTS FROM $TABLE_EMPLOYEES), 0);");

          await db.execute("DROP TABLE $TABLE_EMPLOYEES;");
          await db.execute("ALTER TABLE tmp RENAME TO $TABLE_EMPLOYEES;");
          await db.execute("COMMIT;");
          await db.execute("PRAGMA foreign_keys = ON;");
        }
        if (oldVersion < 6) {
          print("Updating DB v6");
          await db.insert(TABLE_SETTINGS, {COLUMN_H24: 0});
        }
        if (oldVersion < 7) {
          print("Updating DB v7");
          await db.execute(
              "ALTER TABLE $TABLE_DEPARTMENTS RENAME COLUMN $COLUMN_ID TO $COLUMN_DEPT_ID;");
        }
      },
    );
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;

    var employees = await db.query(TABLE_EMPLOYEES,
        columns: [
          COLUMN_ID,
          COLUMN_DEPT_ID,
          COLUMN_FIRST_NAME,
          COLUMN_LAST_NAME,
          COLUMN_COLOR,
          COLUMN_PRIORITY,
          COLUMN_SHIFTS
        ],
        orderBy: COLUMN_PRIORITY);
    List<Employee> empList = List<Employee>();

    employees.forEach((emp) => empList.add(Employee.fromMap(emp)));

    return empList;
  }

  Future<List<Department>> getDepartments() async {
    final db = await database;

    var depts = await db
        .query(TABLE_DEPARTMENTS, columns: [COLUMN_DEPT_ID, COLUMN_DEPT_NAME]);

    List<Department> deptList = List<Department>();

    depts.forEach((dept) => deptList.add(Department.fromMap(dept)));

    return deptList;
  }

  Future<Map<String, dynamic>> getSettings() async {
    final db = await database;

    var settings = await db.query(TABLE_SETTINGS, columns: [COLUMN_H24]);

    return settings[0];
  }

  Future<int> count() async {
    final db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $TABLE_EMPLOYEES"));
  }

  Future<int> countDepts() async {
    final db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $TABLE_DEPARTMENTS"));
  }

  Future<Employee> insertEmployee(Employee emp) async {
    final db = await database;
    print(emp.toMap());
    emp.id = await db.insert(TABLE_EMPLOYEES, emp.toMap());
    return emp;
  }

  Future<Department> insertDept(Department dept) async {
    final db = await database;
    dept.id = await db.insert(TABLE_DEPARTMENTS, dept.toMap());
    return dept;
  }

  Future<int> updateEmployee(int id, Employee emp) async {
    final db = await database;

    return await db.update(TABLE_EMPLOYEES, emp.toMap(),
        where: "$COLUMN_ID = ?", whereArgs: [id]);
  }

  Future<int> updateDept(int id, Department dept) async {
    final db = await database;

    return await db.update(TABLE_DEPARTMENTS, dept.toMap(),
        where: "$COLUMN_DEPT_ID = ?", whereArgs: [id]);
  }

  Future<int> updateSettings(Map<String, dynamic> settings) async {
    final db = await database;
    bool is24 = settings['H24'];

    return await db.update(
        TABLE_SETTINGS, is24 ? {COLUMN_H24: 1} : {COLUMN_H24: 0},
        where: "$COLUMN_ID = 1");
  }

  Future<int> deleteEmployee(int id) async {
    final db = await database;

    return await db
        .delete(TABLE_EMPLOYEES, where: "$COLUMN_ID = ?", whereArgs: [id]);
  }

  Future<int> deleteDept(int id) async {
    final db = await database;

    await db
        .delete(TABLE_EMPLOYEES, where: "$COLUMN_DEPT_ID = ?", whereArgs: [id]);

    return await db.delete(TABLE_DEPARTMENTS,
        where: "$COLUMN_DEPT_ID = ?", whereArgs: [id]);
  }
}
