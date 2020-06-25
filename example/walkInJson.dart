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
    if (someone.interest != null) {
      print('\t ${someone.name} loves :');
      for (var anInterest in someone.interest) print('\t\t $anInterest');
    }
    if (someone.color != null)
      print('\t${someone.name} prefers the ${someone.color} color');
  }

  print(
      '\nSample 2: --------------- read a json string and walk into through dot notation ----- ');
  // uses a long json string in Dart. See unit tests to read a file
  dynamic persons = MapList(personInDart);
  // loop using .lenght on a MapListList
  for (int i = 0; i < persons.length; i++) {
    print('Person:');
    var aPerson = persons[i];
    // aPerson is a MapListMap : can iterate with in keys
    for (var key in aPerson.keys) {
      var result = aPerson[key];
      // result is changing : either a simple data, either a MapListList for contacts key
      if (key == "contacts") {
        print('\t$key elements:');
        // iterate in a MapListList made of several MapListMap
        for (var aContact in result) {
          // iterate on a MapListMap
          aContact.forEach((key, value) {
            print('\t\t\t $key: $value');
          });
          print('\t\t\t---');
        }
      } else
        // other key than contacts
        print('\t$key : $result ');
    }
  }

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
  // execute previous script to set the data
  for (var aStep in script) {
    root_i.exec(aStep);
  }

/*
 verifying data
 Better to do that in code, but try to use interpreter too.
 */
  print('We already have ${root_i.exec('contacts.length')} friends :');
/*
  loop on a MapList is restricted to indices
 */
  for (int i = 0; i < root_i.exec('contacts.length'); i++) {
    // 'i' is not known by interpreter, so must convert before call :
    dynamic someone = root_i.exec('contacts[$i]');
    // cannot do root_i.exec('someone.interest'); as someOne is in code.
    // either use full chain 'like below,
    // either change origin of intepreter in code : someone.exec('interest');
    if (root_i.exec('contacts[$i].interest') != null) {
      print('\t${someone.name} loves:');
      for (var anInterest in someone.interest) print('\t\t${anInterest}');
    }
    if (someone.color != null)
      print('\t${someone.name} prefers the ${someone.color} color');
  }
}
