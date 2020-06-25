/*
 This example is quite a test case.

 It creates by code a full json structure, and verify some entries by code.

 Then a list of commands are executer from a text file.
 Final verifications are done.

 */


import 'package:map_list_dot/map_list_dot.dart';

import 'resources/personInDart.dart';

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  print("""
  *********************************************************
  *** invite you to have a look on unit tests in github ***
  *********************************************************
      Some short examples here to start understanding 
                        ******
  """);

  print(
      '\nSample 1: --------------- create some data by hand and loop on list ----- ');
  /*
   create some data by hand (more easy to read a json, but for demonstration purpose)
   */
  dynamic root = MapList();
  root.contacts = [];
  // creating a MapList allows dot notation including creation
  dynamic person = MapList();
  person.name = 'Peter';
  person.age = 44;
  // can create inline maps & lists
  person.interest = ["litterature", "sport", "video games"];
  root.contacts.add(person);
  // dont reuse the same as it is pointers, create a new one
  person = MapList();
  person.name = 'Lily';
  person.age = 35;
  person.interest = ["nature", "maths", "golf"];
  root.contacts.add(person);
  // can have different keys
  person = MapList();
  person.name = 'Jimmy';
  person.age = 20;
  person.color = 'blue';
  root.contacts.add(person);
/*
 verifying data
 */
  print('We already have ${root.contacts.length} friends:');
/*
  loop on a MapList is restricted to indices
 */
  for (int i = 0; i < root.contacts.length; i++) {
    dynamic someone = root.contacts[i];
    if (someone.interest != null){
      print('\t ${someone.name} loves :');
      /*type 'MapListList' is not a subtype of type 'Iterable<dynamic>'
      for (var anInterest in someone.interest) print('\t\t $anInterest');
      */
      print('\t\t ${someone.interest}');
    }
    if (someone.color != null)
      print('\t${someone.name} prefers the ${someone.color} color');
  }

  print('\nSample 2: --------------- read a json string and walk into  ----- ');
  // uses a long json string in Dart. See unit tests to read a file
  dynamic persons = MapList(personInDart);
  for (int i = 0; i < persons.length; i++) {
    // using a dynamic, the return data will be another MapList that allows dot notation
    dynamic aContact = persons[i];
    print('Person: ${aContact.firstName} ${aContact.name}');
    // iterate on a map
    for (var key in aContact.keys) {
      dynamic leaf = aContact[key];
      print('\t$key: $leaf');
    }
  }
  // and so on

  print('\nSample 3: --------------- same as 1 with interpreter  ----- ');
  var script = <String>[
    'contacts = []',
    // a large json compatible string
    'contacts.add({"name": "peter", "age": 44, "interest":["litterature", "sport", "video games"]   })',
    // just a piece of cake
    'contacts.add({"name": "Lily"})',
    // completed with keyword last and do notation in the script
    'contacts[last].age = 35',
    'contacts[last].interest = ["nature", "maths", "golf"]',
    'contacts.add({"name": "Jimmy", "age": 20 })',
    'contacts[last].color = "blue"',
  ];


  dynamic root_i = MapList();
  // execute previous script
  for (var aStep in script){
    root_i.exec(aStep);
  }

/*
 verifying data
 Better to do that in code, but try to use interpreter too.
 */
  print('We already have ${root_i.exec('contacts.length')} friends');
/*
  loop on a MapList is restricted to indices
 */
  for (int i = 0; i < root_i.exec('contacts.length'); i++) {
    // 'i' is not known by interpreter, so must convert before call :
    dynamic someone = root_i.exec('contacts[$i]');
    // 'someone' is not known by interpreter :
    // cannot do root_i.exec('someone.interest');
    // either use full chain 'root_i.exec('contacts[$i].interest');
    // either change origin of intepreter in code :
    if (someone.exec('interest') != null)
      print('${someone.name} loves \n\t${someone.interest}');
    if (someone.color != null)
      print('${someone.name} prefers the ${someone.color} color');
  }
}
