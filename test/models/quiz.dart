import 'question.dart';

class Quiz{
  String name;
  Map<String, Question> questions={};
  Quiz(this.name);
  void add(Question q)=>questions[q.name]=q;
}