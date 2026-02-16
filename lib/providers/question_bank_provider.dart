import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/question_bank.dart';

class QuestionBankProvider extends ChangeNotifier {
  List<QuestionBank> _banks = [];
  bool _isLoading = false;
  String? _error;
  
  final DatabaseService _dbService = DatabaseService();
  
  List<QuestionBank> get banks => _banks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadBanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _banks = await _dbService.getAllQuestionBanks();
      _error = null;
    } catch (e) {
      _error = 'Failed to load question banks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> addBank(QuestionBank bank, List<Map<String, dynamic>> fields) async {
    try {
      await _dbService.createQuestionBank(bank, fields);
      await loadBanks();
      return true;
    } catch (e) {
      _error = 'Failed to create bank: $e';
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}