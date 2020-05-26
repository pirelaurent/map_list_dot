import 'quiz.dart';

class Survey{
  String name;
  Map <String, Quiz> quiz={};
  Survey(this.name);
  void add(Quiz aQuiz){
    quiz[aQuiz.name] = aQuiz;
  }
}