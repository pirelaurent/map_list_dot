import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected,
      "\nexpected: $expected  ${expected.runtimeType} got: $what ${what.runtimeType}");
}

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });


  dynamic root;

  test("assignment to add & replace data in Map & List", () {
    root = MapList();
    // check creation
    // as we plan to add heterogeneous data in that map we cast
    root.dico = <String,dynamic> {"US": "hello", "FR": "bonjour"};
    root.dico.addAll({"JP": "こんにちは"});
    assert(root.dico.FR == 'bonjour');
    assert(root.dico.JP == 'こんにちは');
    // check modification
    root.dico.FR = "salut";
    assert(root.dico.FR == 'salut');
    //check length
    assert(root.dico.length == 3);
    // change type of an entry
    root.dico.FR = ["bonjour", "salut", "helloxx"];
    assert(root.dico.length == 3);
    root.dico.FR[2] = "hello";
    assert(root.dico.FR.length == 3);
    // change by code, verify by interpreter
    assert(root.dico.FR[0] == "bonjour");
    assert(root.get('dico.FR[1]') == "salut");
    // change by interpreter. verify by code
    root.set('dico.FR[2] = "comment va"');
    assert(root.dico.FR[2] == "comment va");
  });

  test('create new data from scratch in several ways', () {
    dynamic squad = MapList();
    squad.name = "Super hero squad"; // String entry
    assert(squad.name == "Super hero squad");
    squad.members = []; // Empty list names members
    assert(squad.members.isEmpty);
    // create a member with a compiled map json
    squad.members.add({
      "name": "Molecule Man",
      "age": 29,
      "secretIdentity": "Dan Jukes",
      "powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]
    });
    assert(squad.members[0].age == 29);
    // create another member using first a MapList
    dynamic aMember = MapList();
    aMember.name = "Madame Uppercut";
    aMember.age = 39;
    aMember.secretIdentity = "Jane Wilson";
    aMember.powers = [
      "Million tonne punch",
      "Damage resistance",
      "Superhuman reflexes"
    ];
    squad.members.add(aMember);
    assert(squad.members[1].powers[2] == "Superhuman reflexes");
  });





  test("deep changes mixed with interpreter and code from file ", () {
    var testFile = path.join(
        Directory.current.path, 'test', 'models', 'json', 'super_heroes.json');
    var file = File(testFile);
    var jsonString = file.readAsStringSync();
    dynamic squad = MapList(jsonString);
    assert(squad.members[0].powers[1] == "Turning tiny");
    // change by code, test by code & script
    squad.members[0].powers[1] = "Turning heavy";
    squad.set('members[0].powers[1] = "Turning heavy"');
    assert(squad.members[0].powers[1] == "Turning heavy");
    // change by script, test by execand code
    squad.set('members[0].powers[1] = "Turning weird"');
    assert(squad.members[0].powers[1] == "Turning weird");
    assert(squad.get('members[0].powers[1]') == "Turning weird");
  });
}
