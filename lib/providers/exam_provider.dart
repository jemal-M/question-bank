import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/question.dart';

class ExamProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _currentQuestions = [];
  Map<int, dynamic> _userAnswers = {};
  Map<int, bool> _bookmarkedQuestions = {};
  int _currentIndex = 0;
  int _score = 0;
  bool _isCompleted = false;
  Stopwatch _timer = Stopwatch();
  
  final DatabaseService _dbService = DatabaseService();
  
  List<Map<String, dynamic>> get currentQuestions => _currentQuestions;
  Map<int, dynamic> get userAnswers => _userAnswers;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isCompleted => _isCompleted;
  String get elapsedTime => _formatElapsedTime();
  
  Future<void> loadQuestionsForBank(int bankId) async {
    try {
      _currentQuestions = await _dbService.getQuestions(bankId);
      _userAnswers.clear();
      _bookmarkedQuestions.clear();
      _currentIndex = 0;
      _score = 0;
      _isCompleted = false;
      _timer.reset();
      _timer.start();
      notifyListeners();
    } catch (e) {
      print('Error loading questions: $e');
    }
  }
  
  void answerQuestion(int questionIndex, dynamic answer) {
    _userAnswers[questionIndex] = answer;
    notifyListeners();
  }
  
  void nextQuestion() {
    if (_currentIndex < _currentQuestions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }
  
  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }
  
  void jumpToQuestion(int index) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }
  
  void toggleBookmark(int questionIndex) {
    if (_bookmarkedQuestions.containsKey(questionIndex)) {
      _bookmarkedQuestions.remove(questionIndex);
    } else {
      _bookmarkedQuestions[questionIndex] = true;
    }
    notifyListeners();
  }
  
  bool isBookmarked(int questionIndex) {
    return _bookmarkedQuestions.containsKey(questionIndex);
  }
  
  void submitExam() {
    _timer.stop();
    _calculateScore();
    _isCompleted = true;
    notifyListeners();
  }
  
  void _calculateScore() {
    _score = 0;
    for (int i = 0; i < _currentQuestions.length; i++) {
      if (_userAnswers.containsKey(i)) {
        // In a real app, you'd compare with correct answer from question data
        // For now, just a placeholder
        _score++;
      }
    }
  }
  
  void resetExam() {
    _userAnswers.clear();
    _bookmarkedQuestions.clear();
    _currentIndex = 0;
    _score = 0;
    _isCompleted = false;
    _timer.reset();
    _timer.start();
    notifyListeners();
  }
  
  String _formatElapsedTime() {
    final elapsed = _timer.elapsed;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  List<int> get unansweredQuestions {
    List<int> unanswered = [];
    for (int i = 0; i < _currentQuestions.length; i++) {
      if (!_userAnswers.containsKey(i)) {
        unanswered.add(i);
      }
    }
    return unanswered;
  }
  
  List<int> get bookmarkedQuestions {
    return _bookmarkedQuestions.keys.toList();
  }
  
  @override
  void dispose() {
    _timer.stop();
    super.dispose();
  }
}