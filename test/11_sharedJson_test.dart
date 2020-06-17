import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';


class Person {
  Map<String, dynamic> json_data ={};

  get name => json_data["name"];

  get age => json_data["age"];

  get scores => json_data["scores"];

  Person(String aName, int anAge) {
    json_data["name"] = aName;
    json_data["age"] = anAge;
  }
  @override
  String toString(){
    return json_data.toString();
  }
}

void main() {
  /*
  List<int> intList = [10,11,12];
  print('$intList, ${intList.runtimeType}');
  print( intList is List);
  print(intList is List<int>);
  print(intList is List<String>);
  print(intList is List<dynamic>);
  // refused by compiler intList.add("zaza");
  List<dynamic> x = intList.cast(); // cree une surclasse de cast
  print('x ${x.runtimeType}');
  // x.add("zaza"); autorisé par le compilateur mais runtime crash

  List<String> stringList = ["A","B","C"];
  print(stringList);
  print( stringList is List);
  print(stringList is List<int>);
  print(stringList is List<String>);
  print(stringList is List<dynamic>);
  //refused by compiler   stringList.add(12);

  List<dynamic> dynaList = [10,11,12];
  print(dynaList);
  print( dynaList is List);
  print(dynaList is List<int>);
  print(dynaList is List<String>);
  print(dynaList is List<dynamic>);

  return;


   */




  test('constructor with a json entry shared with program', () {
    var p1 = Person('polo', 33);
// create a general level to share data through a dict entry
    dynamic root = MapList({});
// create an entry 'people' which will be a list of person
    root.people = [];
    root.people.add(p1.json_data);
    // test access with dot notation
    assert(root.people[0].name == 'polo');
    // and with interpreter
    assert(root.get('people[0].name') == 'polo');
    // now if we change in MapList, will we chane in p1 ?
    // use last which is equivalent to [0] for this example
    root.people.last.name = 'zaza';
    assert(root.people[0].name == 'zaza');
    assert(p1.name == 'zaza', 'found : ${p1.name}');
  });
}
