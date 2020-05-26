
import 'dart:convert';


import 'models/option.dart';
import 'models/question.dart';
import 'models/quiz.dart';
import 'models/survey.dart';

void main() {

  var mySurveys={};
  var aSurvey = Survey("food inquiry");
  mySurveys["food"]=aSurvey;
  var aQuiz = Quiz('pizza');
  aSurvey.add(aQuiz);
  var aQuestion = Question("preference","What is your prefered Pizza ?");
  aQuiz.add(aQuestion);
  var anOption =
  aQuestion.addOption(Option(1,"Margarita"));
  aQuestion.addOption(Option(2,"Regina"));
  aQuestion.addOption(Option(3,"Neapolitan"));


  var x = mySurveys["food"].quiz["pizza"].questions["preference"].options[1].askText;
   var secondChoice ="quiz.pizza.questions.preference.options[1].askText";
   print(mySurveys);
}