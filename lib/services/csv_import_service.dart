import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:exampapp/models/question_bank.dart';
import 'package:file_picker/file_picker.dart';
import 'database_service.dart';

class CSVImportService {
  final DatabaseService _dbService = DatabaseService();
  
  // Import CSV and create new question bank
  Future<Map<String, dynamic>> importCSVAsNewBank() async {
    try {
      // Pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );
      
      if (result == null) {
        return {'success': false, 'message': 'No file selected'};
      }
      
      // Read file bytes
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        return {'success': false, 'message': 'Could not read file'};
      }
      
      // Parse CSV
      final csvString = utf8.decode(bytes);
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
      
      if (rows.isEmpty) {
        return {'success': false, 'message': 'CSV file is empty'};
      }
      
      // First row should be headers (field names)
      List<String> headers = rows.first.map((cell) => cell.toString()).toList();
      
      // Auto-detect field types based on data
      List<Map<String, dynamic>> fields = _detectFieldTypes(headers, rows);
      
      // Preview data for user
      List<Map<String, dynamic>> previewData = [];
      for (int i = 1; i < rows.length && i < 6; i++) {
        Map<String, dynamic> rowData = {};
        for (int j = 0; j < headers.length; j++) {
          rowData[headers[j]] = rows[i][j];
        }
        previewData.add(rowData);
      }
      
      return {
        'success': true,
        'headers': headers,
        'fields': fields,
        'previewData': previewData,
        'rowCount': rows.length - 1, // Subtract header row
        'rawData': rows,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error importing CSV: $e'};
    }
  }
  
  List<Map<String, dynamic>> _detectFieldTypes(List<String> headers, List<List<dynamic>> rows) {
    List<Map<String, dynamic>> fields = [];
    
    for (int i = 0; i < headers.length; i++) {
      String header = headers[i];
      
      // Determine field type by examining first few data rows
      String fieldType = 'text'; // default
      
      for (int j = 1; j < rows.length && j < 11; j++) { // Check first 10 rows
        if (j >= rows.length) break;
        
        var value = rows[j][i];
        
        if (value is num) {
          fieldType = 'number';
          break;
        } else if (value.toString().toLowerCase() == 'true' || 
                   value.toString().toLowerCase() == 'false') {
          fieldType = 'boolean';
          break;
        }
      }
      
      fields.add({
        'fieldName': _generateFieldName(header),
        'fieldType': fieldType,
        'displayName': header,
        'isRequired': false,
        'displayOrder': i,
      });
    }
    
    return fields;
  }
  
  String _generateFieldName(String header) {
    // Convert header to valid SQLite column name
    return header
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }
  
  // Create question bank from CSV
  Future<Map<String, dynamic>> createBankFromCSV(
    String bankName,
    String description,
    List<Map<String, dynamic>> fields,
    List<List<dynamic>> csvData,
  ) async {
    try {
      // Create question bank
      final bank = QuestionBank(
        name: bankName,
        description: description,
        createdAt: DateTime.now(), questionCount: 0, config: {}, filePath: '',
      );
      
      final bankId = await _dbService.createQuestionBank(bank, fields);
      
      // Import questions
      List<String> headers = csvData.first.map((cell) => cell.toString()).toList();
      fields.asMap();
      
      for (int i = 1; i < csvData.length; i++) {
        Map<String, dynamic> questionData = {};
        
        for (int j = 0; j < headers.length; j++) {
          questionData[_generateFieldName(headers[j])] = csvData[i][j];
        }
        
        await _dbService.addQuestion(bankId, questionData);
      }
      
      return {
        'success': true,
        'bankId': bankId,
        'message': 'Successfully imported ${csvData.length - 1} questions',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error creating bank: $e'};
    }
  }
  
  // Export question bank to CSV
  Future<Map<String, dynamic>> exportBankToCSV(int bankId) async {
    try {
      // Get fields
      final fields = await _dbService.getBankFields(bankId);
      final fieldNames = fields.map((f) => f['fieldName'] as String).toList();
      final displayNames = fields.map((f) => f['displayName'] as String).toList();
      
      // Get questions
      final questions = await _dbService.getQuestions(bankId);
      
      // Create CSV data
      List<List<dynamic>> csvData = [];
      csvData.add(displayNames); // Header row with display names
      
      for (var question in questions) {
        List<dynamic> row = [];
        for (var fieldName in fieldNames) {
          row.add(question[fieldName] ?? '');
        }
        csvData.add(row);
      }
      
      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);
      
      return {
        'success': true,
        'data': csvString,
        'rowCount': questions.length,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error exporting bank: $e'};
    }
  }
}