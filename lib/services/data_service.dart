import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/question_bank.dart';
import '../models/question.dart';
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
    final path = join(documentsDirectory.path, Constants.databaseName);
    
    return await openDatabase(
      path,
      version: Constants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create banks table
    await db.execute('''
      CREATE TABLE ${Constants.tableBanks}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        questionCount INTEGER DEFAULT 0,
        config TEXT
      )
    ''');
    
    // Create bank configurations table for field definitions
    await db.execute('''
      CREATE TABLE ${Constants.tableConfig}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bankId INTEGER NOT NULL,
        fieldName TEXT NOT NULL,
        fieldType TEXT NOT NULL,
        displayName TEXT,
        isRequired INTEGER DEFAULT 0,
        displayOrder INTEGER,
        FOREIGN KEY (bankId) REFERENCES ${Constants.tableBanks}(id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle upgrades if needed
  }
  
  // Dynamic table creation for question banks
  Future<void> createQuestionBankTable(int bankId, List<Map<String, dynamic>> fields) async {
    final db = await database;
    final tableName = 'bank_${bankId}_questions';
    
    // Build CREATE TABLE statement dynamically based on fields
    StringBuffer createSQL = StringBuffer('''
      CREATE TABLE IF NOT EXISTS $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        createdAt TEXT NOT NULL
    ''');
    
    // Add dynamic columns based on field configurations
    for (var field in fields) {
      String columnType = _mapFieldTypeToSQLite(field['fieldType']);
      createSQL.write(', ${field['fieldName']} $columnType');
    }
    
    createSQL.write(')');
    
    await db.execute(createSQL.toString());
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
  
  // Question Bank CRUD Operations
  Future<int> createQuestionBank(QuestionBank bank, List<Map<String, dynamic>> fields) async {
    final db = await database;
    
    // Insert bank record
    final bankId = await db.insert(Constants.tableBanks, {
      'name': bank.name,
      'description': bank.description,
      'createdAt': bank.createdAt.toIso8601String(),
      'questionCount': 0,
      'config': json.encode(bank.config),
    });
    
    // Insert field configurations
    for (var field in fields) {
      await db.insert(Constants.tableConfig, {
        'bankId': bankId,
        'fieldName': field['fieldName'],
        'fieldType': field['fieldType'],
        'displayName': field['displayName'],
        'isRequired': field['isRequired'] ? 1 : 0,
        'displayOrder': field['displayOrder'],
      });
    }
    
    // Create dynamic table for questions
    await createQuestionBankTable(bankId, fields);
    
    return bankId;
  }
  
  Future<List<QuestionBank>> getAllQuestionBanks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(Constants.tableBanks);
    
    return List.generate(maps.length, (i) {
      return QuestionBank.fromMap(maps[i]);
    });
  }
  
  // Question Operations
  Future<int> addQuestion(int bankId, Map<String, dynamic> questionData) async {
    final db = await database;
    final tableName = 'bank_${bankId}_questions';
    
    // Add createdAt
    questionData['createdAt'] = DateTime.now().toIso8601String();
    
    // Insert question
    final questionId = await db.insert(tableName, questionData);
    
    // Update question count in banks table
    await db.update(
      Constants.tableBanks,
      {'questionCount': raw('questionCount + 1')},
      where: 'id = ?',
      whereArgs: [bankId],
    );
    
    return questionId;
  }
  
  Future<List<Map<String, dynamic>>> getQuestions(int bankId) async {
    final db = await database;
    final tableName = 'bank_${bankId}_questions';
    
    // Check if table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'"
    );
    
    if (tables.isEmpty) return [];
    
    return await db.query(tableName);
  }
  
  // Get field configuration for a bank
  Future<List<Map<String, dynamic>>> getBankFields(int bankId) async {
    final db = await database;
    return await db.query(
      Constants.tableConfig,
      where: 'bankId = ?',
      whereArgs: [bankId],
      orderBy: 'displayOrder ASC',
    );
  }
}