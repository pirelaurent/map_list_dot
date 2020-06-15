/*
 This example is quite a test case.

 It creates by code a full json structure, and verify some entries by code.

 Then a list of commands are executer from a text file.
 Final verifications are done.

 */
import 'dart:convert';

import 'package:map_list_dot/map_list_dot.dart';

import 'resources/personInDart.dart';

void main() {
  print(
      'Sample 1: --------------- create some data by hand and loop on list ----- ');
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
  // reuse of the same to verify isolation
  person.clear();
  person.name = 'Lily';
  person.age = 35;
  person.interest = ["nature", "maths", "golf"];
  root.contacts.add(person);
  // can have different keys
  person.clear();
  person.name = 'Jimmy';
  person.age = 20;
  person.color = 'blue';
  root.contacts.add(person);
/*
 verifying data
 */
  print('We already have ${root.contacts.length} friends');
/*
  loop on a MapList is restricted to indices
 */
  for (int i = 0; i < root.contacts.length; i++) {
    dynamic someone = root.contacts[i];
    if (someone.interest != null)
      print('${someone.name} loves ${someone.interest}');
    if (someone.color != null)
      print('${someone.name} prefers the ${someone.color} color');
  }

  print('Sample 2: --------------- read a json string and explore ----- ');
  // uses a long json string in Dart. See unit tests to read a file
  dynamic persons = MapList(personInDart);
  for (int i = 0; i < persons.length; i++) {
    // using a dynamic, the return data will be another MapList that allows dot notation
    dynamic aContact = persons[i];
    print('${aContact.firstName} ${aContact.name}');
    // iterate on a map
    for (var key in aContact.keys) {
      dynamic leaf = aContact[key];
      print('$key: $leaf');
    }
  }
  // and so on

  print('Sample 3: --------------- same as 1 with interpreter  ----- ');
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
 */
  print('We already have ${root_i.contacts.length} friends');
/*
  loop on a MapList is restricted to indices
 */
  for (int i = 0; i < root_i.get('contacts.length'); i++) {
    // remember scripted with strin; So [$i]
    dynamic someone = root_i.get('contacts[$i]');
    if (root_i.get('someone.interest') != null)
      print('${someone.name} loves ${someone.interest}');
    if (someone.color != null)
      print('${someone.name} prefers the ${someone.color} color');
  }
}
