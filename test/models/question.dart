import 'option.dart';

class Question{
  String name;
  String subject;
  List <Option> options=[];
  Question(this.name, this.subject);
  void addOption(var o)=> options.add(o);
}
