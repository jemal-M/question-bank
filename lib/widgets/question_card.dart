import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionNumber;
  final int totalQuestions;
  final dynamic selectedAnswer;
  final ValueChanged<dynamic> onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.selectedAnswer?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = widget.selectedAnswer?.toString() ?? '';
    if (_textController.text != value) {
      _textController.text = value;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.question['question']?.toString() ??
        widget.question['prompt']?.toString() ??
        'Question ${widget.questionNumber}';

    final rawOptions = widget.question['options'];
    final options = rawOptions is List ? rawOptions.map((e) => e.toString()).toList() : <String>[];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${widget.questionNumber} of ${widget.totalQuestions}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              prompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (options.isNotEmpty)
              ...options.map(
                (option) => RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: option,
                  groupValue: widget.selectedAnswer?.toString(),
                  title: Text(option),
                  onChanged: (value) {
                    if (value != null) {
                      widget.onAnswerSelected(value);
                    }
                  },
                ),
              )
            else
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your answer',
                ),
                onChanged: widget.onAnswerSelected,
              ),
          ],
        ),
      ),
    );
  }
}
