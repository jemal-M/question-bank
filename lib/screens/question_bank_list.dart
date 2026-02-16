import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_bank_provider.dart';

class QuestionBankListScreen extends StatefulWidget {
  @override
  _QuestionBankListScreenState createState() => _QuestionBankListScreenState();
}

class _QuestionBankListScreenState extends State<QuestionBankListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestionBankProvider>(context, listen: false).loadBanks();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Banks'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<QuestionBankProvider>(context, listen: false).loadBanks();
            },
          ),
        ],
      ),
      body: Consumer<QuestionBankProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading banks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(provider.error!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadBanks();
                    },
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          if (provider.banks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Question Banks Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Import a CSV file to create your first bank',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/import');
                    },
                    icon: Icon(Icons.upload_file),
                    label: Text('Import CSV'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: provider.banks.length,
            itemBuilder: (context, index) {
              final bank = provider.banks[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    bank.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bank.description.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(bank.description),
                      ],
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.question_answer, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('${bank.questionCount} questions'),
                          SizedBox(width: 16),
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('${bank.createdAt.toString().split(' ')[0]}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.play_arrow, color: Colors.green),
                          title: Text('Start Exam'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Practice'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.download, color: Colors.purple),
                          title: Text('Export CSV'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to bank details/questions list
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/import');
        },
        icon: Icon(Icons.add),
        label: Text('New Bank'),
      ),
    );
  }
}