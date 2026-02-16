import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_bank_provider.dart';
import 'question_bank_list.dart';
import 'admin/import_bank_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Prep Platform'),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Exam Preparation Platform',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dynamic question banks for any licensing exam',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Main Action Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    context,
                    title: 'Start Exam',
                    icon: Icons.play_circle_filled,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/banks');
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Practice Mode',
                    icon: Icons.edit,
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to practice mode
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Question Banks',
                    icon: Icons.library_books,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/banks');
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Import CSV',
                    icon: Icons.upload_file,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, '/import');
                    },
                  ),
                ],
              ),
            ),
            
            // Quick Stats Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Consumer<QuestionBankProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.folder,
                        value: '${provider.banks.length}',
                        label: 'Banks',
                      ),
                      _buildStatItem(
                        icon: Icons.question_answer,
                        value: '0',
                        label: 'Questions',
                      ),
                      _buildStatItem(
                        icon: Icons.trending_up,
                        value: '0%',
                        label: 'Avg. Score',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
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
}