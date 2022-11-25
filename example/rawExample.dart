/*
 This example is quite a test case.

 It creates by code a full json structure, and verify some entries by code.

 Then a list of commands are executed from a text file.
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
//------------------------
  print(
      '\nSample 1: --------------- create some data by hand and loop on  ----- ');
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
 verifying data.
 use length
 */
  print('We already have ${root.contacts.length} friends:');
/*
  loop on a MapListList with indices
 */
  for (int i = 0; i < root.contacts.length; i++) {
    dynamic someone = root.contacts[i];
    if (someone.interest != null) {
      print('\t ${someone.name} loves :');
      // loop on a MapListList with iterator
      for (var anInterest in someone.interest) print('\t\t $anInterest');
    }
    if (someone.color != null)
      print('\t${someone.name} prefers the ${someone.color} color');
  }

//------------------------
  print(
      '\nSample 2: --------------- read a json string and walk into through dot notation ----- ');
  // uses a long json string in Dart. See unit tests to read a file
  dynamic persons = MapList(personInDart);
  // loop using .lenght on a MapListList
  for (int i = 0; i < persons.length; i++) {
    print('Person:');
    // using indices
    var aPerson = persons[i];
    // aPerson is a MapListMap : can iterate with 'in' keys
    for (var key in aPerson.keys) {
      var result = aPerson[key];
      // result is changing : either a simple data, either a MapListList for contacts key
      if (key == "contacts") {
        print('\t$key elements:');
        // iterate in a MapListList (made of several MapListMap)
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
  print('---------- some dot notation samples in dart code ----------');
  print('persons -> \n\t${persons}');
  print('persons[1]]->\n\t${persons[1]}');
  print('persons[1].contacts -> \t\t\t${persons[1].contacts}');
  print('persons[1].contacts[0] -> \t\t${persons[1].contacts[0]}');
  print('persons[1].contacts[0].mail -> \t${persons[1].contacts[0].mail}');

//------------------------
  print('\nSample 3: -create data with script   ----- ');
  var scriptList = <String>[
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

  root = MapList();
  // execute previous script to set the data
  for (var aStep in scriptList) {
    root.eval(aStep);
  }

  print('---------- some dot notation samples in script----------');
  String script;
  script = '';
  print("root.eval('$script') -> \n\t${root.eval(script)}");
  script = 'contacts';
  print("root.eval('$script') -> \n\t  ${root.eval(script)}");
  script = 'contacts[0]';
  print("root.eval('$script') -> ${root.eval(script)}");
  script = 'contacts[0].interest';
  print("root.eval('$script') -> ${root.eval(script)}");
  script = 'contacts[0].interest[1]';
  print("root.eval('$script') -> ${root.eval(script)}");
  print('-------------------------------------------------');

/*
 verifying data
 Better to do that in code, but try to use interpreter too.
 */
  print('We already have ${root.eval('contacts.length')} friends :');
/*
  loop on a MapList is restricted to indices
 */
  for (int i = 0; i < root.eval('contacts.length'); i++) {
    // 'i' is not known by interpreter, so must convert before call :
    dynamic someone = root.eval('contacts[$i]');
    // cannot do root_i.eval('someone.interest'); as someOne is in code.
    // either use full chain 'like below,
    // either change origin of intepreter in code : someone.eval('interest');
    if (root.eval('contacts[$i].interest') != null) {
      print('\t${someone.name} loves:');
      for (var anInterest in someone.interest) print('\t\t${anInterest}');
    }
    if (someone.color != null)
      print('\t${someone.name} prefers the ${someone.color} color');
  }
}
