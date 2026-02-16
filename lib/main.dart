import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/question_bank_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/question_bank_list.dart';
import 'screens/admin/import_bank_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // path_provider is not available on web.
  if (!kIsWeb) {
    await DatabaseService().database;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionBankProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Exam Prep Platform',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: HomeScreen(),
        routes: {
          '/banks': (context) => QuestionBankListScreen(),
          '/import': (context) => const ImportBankScreen(),
        },
      ),
    );
  }
}
