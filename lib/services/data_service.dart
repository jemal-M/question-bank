import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/question_bank.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, Constant.dattaBaseNmae);

    return openDatabase(
      path,
      version: Constant.dataBaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Constant.tableBanks}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        questionCount INTEGER DEFAULT 0,
        config TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Constant.tableConfig}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bankId INTEGER NOT NULL,
        fieldName TEXT NOT NULL,
        fieldType TEXT NOT NULL,
        displayName TEXT,
        isRequired INTEGER DEFAULT 0,
        displayOrder INTEGER,
        FOREIGN KEY (bankId) REFERENCES ${Constant.tableBanks}(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> createQuestionBankTable(int bankId, List<Map<String, dynamic>> fields) async {
    final db = await database;
    final tableName = 'bank_${bankId}_questions';

    final createSql = StringBuffer('''
      CREATE TABLE IF NOT EXISTS $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        createdAt TEXT NOT NULL
    ''');

    for (final field in fields) {
      final columnType = _mapFieldTypeToSQLite(field['fieldType'] as String);
      createSql.write(', ${field['fieldName']} $columnType');
    }

    createSql.write(')');
    await db.execute(createSql.toString());
  }

  String _mapFieldTypeToSQLite(String fieldType) {
    switch (fieldType) {
      case 'number':
        return 'REAL';
      case 'boolean':
        return 'INTEGER';
      case 'text':
      default:
        return 'TEXT';
    }
  }

  Future<int> createQuestionBank(QuestionBank bank, List<Map<String, dynamic>> fields) async {
    final db = await database;

    final bankId = await db.insert(Constant.tableBanks, {
      'name': bank.name,
      'description': bank.description,
      'createdAt': bank.createdAt.toIso8601String(),
      'questionCount': 0,
      'config': json.encode(bank.config),
    });

    for (final field in fields) {
      await db.insert(Constant.tableConfig, {
        'bankId': bankId,
        'fieldName': field['fieldName'],
        'fieldType': field['fieldType'],
        'displayName': field['displayName'],
        'isRequired': field['isRequired'] ? 1 : 0,
        'displayOrder': field['displayOrder'],
      });
    }

    await createQuestionBankTable(bankId, fields);
    return bankId;
  }

  Future<List<QuestionBank>> getAllQuestionBanks() async {
    final db = await database;
    final maps = await db.query(Constant.tableBanks);
    return List.generate(maps.length, (i) => QuestionBank.fromMap(maps[i]));
  }

  Future<int> addQuestion(int bankId, Map<String, dynamic> questionData) async {
    final db = await database;
    final tableName = 'bank_${bankId}_questions';

    questionData['createdAt'] = DateTime.now().toIso8601String();
    final questionId = await db.insert(tableName, questionData);

    await db.rawUpdate(
      'UPDATE ${Constant.tableBanks} SET questionCount = questionCount + 1 WHERE id = ?',
      [bankId],
    );

    return questionId;
  }

  Future<List<Map<String, dynamic>>> getQuestions(int bankId) async {
    final db = await database;
    final tableName = 'bank_${bankId}_questions';

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    if (tables.isEmpty) return [];
    return db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> getBankFields(int bankId) async {
    final db = await database;
    return db.query(
      Constant.tableConfig,
      where: 'bankId = ?',
      whereArgs: [bankId],
      orderBy: 'displayOrder ASC',
    );
  }
}
