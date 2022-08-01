import 'package:sqflite/sqflite.dart';
import 'package:sqflite_pof/models/user.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._initialize();
  static Database? _database;
  TodoDatabase._initialize();

  Future _createDB(Database db, int version) async {
    const userUserNameType = 'TEXT PRIMARY KEY NOT NULL';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''CREATE TABLE $userTable (
     ${UserFields.username} $userUserNameType,
     ${UserFields.name} $textType  
   )''');

    await db.execute('''CREATE TABLE $todoTable (
     ${TodoFields.username} $textType,
     ${TodoFields.title} $textType,
     ${TodoFields.done} $boolType,
     ${TodoFields.created} $textType,
     FOREIGN KEY (${TodoFields.username}) REFERENCES $userTable (${UserFields.username})
   )''');
  }

  //for the foreign key
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future close() async {
    final db = await instance.database;
    db!.close();
  }

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDB('todo.db');
      return _database;
    }
  }

  //CRUD for User create
  Future<User> createUser(User user) async {
    final db = await instance.database;
    await db!.insert(
      userTable,
      user.toJson(),
    );
    return user;
  }

  //Read a singular user
  Future<User> getUser(String username) async {
    final db = await instance.database;
    final maps = await db!.query(userTable,
        columns: UserFields.allFields,
        where: '${UserFields.username} = ?',
        whereArgs: [
          username,
        ]);
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('$username not found in this database');
    }
  }

  //Read from all users
  Future<List<User>> getUsers() async {
    final db = await instance.database;
    final result = await db!.query(
      userTable,
      orderBy: '${UserFields.username} ASC',
    );
    return result.map((e) => User.fromJson(e)).toList();
  }

  // update User
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return db!.update(
      userTable,
      user.toJson(),
      where: '${UserFields.username} = ?',
      whereArgs: [
        user.username,
      ],
    );
  }

  //delete user
  Future<int> deleteUser(String username) async {
    final db = await instance.database;
    return db!.delete(
      userTable,
      where: '${UserFields.username} = ?',
      whereArgs: [
        username,
      ],
    );
  }

  //CRUD for todo create
  Future<Todo> createTodo(Todo todo) async {
    final db = await instance.database;
    await db!.insert(
      todoTable,
      todo.toJson(),
    );
    return todo;
  }

  Future<int> toggleTodoDone(Todo todo) async {
    final db = await instance.database;
    todo.done = !todo.done;
    return db!.update(
      todoTable,
      todo.toJson(),
      where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
      whereArgs: [
        todo.title,
        todo.username,
      ],
    );
  }

  Future<List<Todo>> getTodos(String username) async {
    final db = await instance.database;
    final result = await db!.query(todoTable,
        orderBy: '${TodoFields.created} DESC',
        where: '${TodoFields.username} = ?',
        whereArgs: [
          username,
        ]);
    return result.map((e) => Todo.fromJson(e)).toList();
  }

  Future<int> deleteTodos(Todo todo) async {
    final db = await instance.database;
    return db!.delete(
      todoTable,
      where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
      whereArgs: [
        todo.title,
        todo.username,
      ],
    );
  }
}
