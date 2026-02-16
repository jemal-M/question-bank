import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/progress_indicator.dart';

class ExamScreen extends StatefulWidget {
  final int bankId;
  final String bankName;
  
  const ExamScreen({
    Key? key,
    required this.bankId,
    required this.bankName,
  }) : super(key: key);
  
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExamProvider>(context, listen: false)
          .loadQuestionsForBank(widget.bankId);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bankName),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Exam'),
            Tab(text: 'Review'),
            Tab(text: 'Bookmarks'),
          ],
        ),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, child) {
          if (provider.currentQuestions.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildExamTab(provider),
              _buildReviewTab(provider),
              _buildBookmarksTab(provider),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildExamTab(ExamProvider provider) {
    if (provider.isCompleted) {
      return _buildResultsScreen(provider);
    }
    
    return Column(
      children: [
        // Timer and Progress Bar
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.blue.shade700),
                  SizedBox(width: 8),
                  Text(
                    provider.elapsedTime,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              CustomProgressIndicator(
                current: provider.currentIndex + 1,
                total: provider.currentQuestions.length,
                color: Colors.blue.shade700,
              ),
              IconButton(
                icon: Icon(
                  provider.isBookmarked(provider.currentIndex)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: provider.isBookmarked(provider.currentIndex)
                      ? Colors.amber
                      : Colors.grey,
                ),
                onPressed: () {
                  provider.toggleBookmark(provider.currentIndex);
                },
              ),
            ],
          ),
        ),
        
        // Question Card
               // Question Card
        Expanded(
          child: QuestionCard(
            question: provider.currentQuestions[provider.currentIndex],
            questionNumber: provider.currentIndex + 1,
            totalQuestions: provider.currentQuestions.length,
            selectedAnswer: provider.userAnswers[provider.currentIndex],
            onAnswerSelected: (answer) {
              provider.answerQuestion(provider.currentIndex, answer);
            },
          ),
        ),
        
        // Navigation Buttons
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (provider.currentIndex > 0)
                ElevatedButton.icon(
                  onPressed: provider.previousQuestion,
                  icon: Icon(Icons.arrow_back),
                  label: Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                  ),
                )
              else
                SizedBox(width: 100),
              
              if (provider.currentIndex < provider.currentQuestions.length - 1)
                ElevatedButton.icon(
                  onPressed: provider.nextQuestion,
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    _showSubmitDialog(context, provider);
                  },
                  icon: Icon(Icons.check_circle),
                  label: Text('Submit Exam'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildReviewTab(ExamProvider provider) {
    if (provider.currentQuestions.isEmpty) {
      return Center(child: Text('No questions to review'));
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.currentQuestions.length,
      itemBuilder: (context, index) {
        final question = provider.currentQuestions[index];
        final isAnswered = provider.userAnswers.containsKey(index);
        
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isAnswered ? Colors.green : Colors.orange,
              child: Text('${index + 1}'),
            ),
            title: Text(
              'Question ${index + 1}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              question['question'] ?? 'No question text',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isBookmarked(index))
                  Icon(Icons.bookmark, color: Colors.amber),
                SizedBox(width: 8),
                Icon(
                  isAnswered ? Icons.check_circle : Icons.help,
                  color: isAnswered ? Colors.green : Colors.orange,
                ),
              ],
            ),
            onTap: () {
              provider.jumpToQuestion(index);
              _tabController.animateTo(0);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildBookmarksTab(ExamProvider provider) {
    final bookmarks = provider.bookmarkedQuestions;
    
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookmarked questions',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Bookmark questions during the exam to review them later',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final questionIndex = bookmarks[index];
        final question = provider.currentQuestions[questionIndex];
        final isAnswered = provider.userAnswers.containsKey(questionIndex);
        
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isAnswered ? Colors.green : Colors.orange,
              child: Text('${questionIndex + 1}'),
            ),
            title: Text(
              'Question ${questionIndex + 1}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              question['question'] ?? 'No question text',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAnswered ? Icons.check_circle : Icons.help,
                  color: isAnswered ? Colors.green : Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.bookmark_remove, color: Colors.red),
                  onPressed: () {
                    provider.toggleBookmark(questionIndex);
                  },
                ),
              ],
            ),
            onTap: () {
              provider.jumpToQuestion(questionIndex);
              _tabController.animateTo(0);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildResultsScreen(ExamProvider provider) {
    final totalQuestions = provider.currentQuestions.length;
    final correctAnswers = provider.score;
    final percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 0;
    
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 70 ? Icons.emoji_events : Icons.repeat,
              size: 100,
              color: percentage >= 70 ? Colors.amber : Colors.blue,
            ),
            SizedBox(height: 24),
            Text(
              percentage >= 70 ? 'Congratulations!' : 'Keep Practicing!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Score',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$correctAnswers / $totalQuestions',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 24,
                      color: percentage >= 70 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // Summary Statistics
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    icon: Icons.timer,
                    value: provider.elapsedTime,
                    label: 'Time Taken',
                  ),
                  _buildSummaryItem(
                    icon: Icons.help_outline,
                    value: '${provider.unansweredQuestions.length}',
                    label: 'Unanswered',
                  ),
                  _buildSummaryItem(
                    icon: Icons.bookmark,
                    value: '${provider.bookmarkedQuestions.length}',
                    label: 'Bookmarked',
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    provider.resetExam();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Retry Exam'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  void _showSubmitDialog(BuildContext context, ExamProvider provider) {
    final unanswered = provider.unansweredQuestions.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Exam?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to submit your exam?'),
            if (unanswered > 0) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have $unanswered unanswered ${unanswered == 1 ? 'question' : 'questions'}',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Review'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.submitExam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}