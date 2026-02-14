class Question {
  final int? id;
  final int bankId;
  final Map<String, dynamic> data; // Dynamic fields based on bank config
  final DateTime createdAt;
  
  Question({
    this.id,
    required this.bankId,
    required this.data,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankId': bankId,
      'data': data.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      bankId: map['bankId'],
      data: _parseData(map['data']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  static Map<String, dynamic> _parseData(String? dataString) {
    if (dataString == null) return {};
    try {
      // Simple parsing - in production, use proper JSON
      return {};
    } catch (e) {
      return {};
    }
  }
}