class ExamConfig {
  final int id;
  final int bankId;
  final String name;
  final int timeLimitMinutes;
  final int totalQuestions;
  final double passingScore;
  final bool randomizeOrder;
  final bool showAnswersImmediately;
  
  ExamConfig({
    required this.id,
    required this.bankId,
    required this.name,
    required this.timeLimitMinutes,
    required this.totalQuestions,
    required this.passingScore,
    required this.randomizeOrder,
    required this.showAnswersImmediately,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankId': bankId,
      'name': name,
      'timeLimitMinutes': timeLimitMinutes,
      'totalQuestions': totalQuestions,
      'passingScore': passingScore,
      'randomizeOrder': randomizeOrder ? 1 : 0,
      'showAnswersImmediately': showAnswersImmediately ? 1 : 0,
    };
  }
}