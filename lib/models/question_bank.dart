class QuestionBank {
    final int? id;
    final String name;
    final String description;
    final DateTime createdAt;
    final int questionCount;
    final Map<String,dynamic> config;

    QuestionBank({
        this.id,
        required this.name,
        required this.description,
         required this.createdAt,
         required this.questionCount,
         required this.config
    });
    Map<String,dynamic> toMap(){
     return {
        'id':id,
        'name':name,
        'description':description,
        'createdAt':createdAt.toIso8601String(),
       'questionCount':questionCount,
       'config':config.toString()
     };
    }
    factory QuestionBank.fromMap(Map<String,dynamic> map){
    return QuestionBank(name: map['name'], 
    description: map['description'],
     createdAt: map['createdAt'], 
     questionCount: map['questionCount'],
      config: map['config']);
    }
    static Map<String,dynamic> _parseConfig(String? configString){
        if(configString==null) return {};
        try{
  return {};
        }
        catch(e){
return {};
        }
    }
}


