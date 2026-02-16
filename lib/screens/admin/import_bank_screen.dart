
import 'package:exampapp/models/question_bank.dart';
import 'package:exampapp/providers/question_bank_provider.dart';
import 'package:exampapp/services/csv_import_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 

class ImportBankScreen extends StatefulWidget {
  const ImportBankScreen({super.key});

  @override
  State<ImportBankScreen> createState() => _ImportBankScreenState();
}
class _ImportBankScreenState extends State<ImportBankScreen> with SingleTickerProviderStateMixin{
  final _bankNameController = TextEditingController();
  final bankDescriptioncontroller=TextEditingController();
  bool _isLoading = false;
  bool _fileSelected = false;
  String? selectedFilePath;
  List<Map<String,dynamic>>? fields=[];
  List<Map<String,dynamic>>? previoeData=[];
  int _roCount=0
;
List<List<dynamic>> _rawData=[];
String? errorMessage;


final CSVImportService _importService=CSVImportService();
late TabController _tabController;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
}

@override
void dispose() {
  _bankNameController.dispose();
  bankDescriptioncontroller.dispose();
  _tabController.dispose();
  super.dispose();
}


Future<void> _pickFile() async{
  setState(() {
    _isLoading=true;
    errorMessage=null;
  });
  try{
final result=await _importService.importCSVAsNewBank();
setState(() {
  _isLoading:true;
  if(result['success']){
    _fileSelected=true;
    selectedFilePath=result['filePath'];
    fields=result['fields'];
    previoeData=result['previewData'];
    _roCount=previoeData?.length??0;
  }
});
  }
  catch(e){
    setState(() {
      errorMessage='Error picking file: $e';
      _isLoading=false;
    });
  }
}

Future<void> _saveBank() async{
  if(selectedFilePath==null){
    setState(() {
      errorMessage='No file selected';
    });
    return;
  }
  if(_bankNameController.text.isEmpty){
    setState(() {
      errorMessage='Please enter a bank name';
    });
    return;
  }
  setState(() {
    _isLoading=true;
    errorMessage=null;
  });
  try{
final questionBank=QuestionBank(
  name: _bankNameController.text,
  description: bankDescriptioncontroller.text,
  filePath: selectedFilePath!, createdAt: DateTime.now(), questionCount: _roCount, config: {},
);
final provider=Provider.of<QuestionBankProvider>(context,listen: false);
provider.addBank(questionBank, fields!);
setState(() {
  _isLoading=false;
});
  } catch(e){
    setState(() {
      errorMessage='Error saving bank: $e';
      _isLoading=false;
    });
  }
}

void _showErrorDialog(String message){
  showDialog(
    context: context,
    builder: (context)=>AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: ()=>Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

void _showSuccessDialog(String message){
  showDialog(
    context: context,
    builder: (context)=>AlertDialog(
      title: Text('Success'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: ()=>Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Question Bank'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Import'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImportTab(),
        ],
      ),
    );
  }

  Widget _buildImportTab(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _bankNameController,
            decoration: InputDecoration(labelText: 'Bank Name'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: bankDescriptioncontroller,
            decoration: InputDecoration(labelText: 'Bank Description'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _pickFile,
            child: Text(_fileSelected ? 'Change File' : 'Select CSV File'),
          ),
          if(errorMessage!=null)...[
            SizedBox(height: 16),
            Text(errorMessage!, style: TextStyle(color: Colors.red)),
          ],
          Spacer(),
          ElevatedButton(
            onPressed:_isLoading ? null : _saveBank,
            child: Text('Save Bank'),
          ),
        ],
      ),
    );
  }
}