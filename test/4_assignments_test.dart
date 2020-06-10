import 'package:map_list_dot/map_list_dot_lib.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected,
  "\nexpected: $expected  ${expected.runtimeType} got: $what ${what
      .runtimeType}");
}

void main() {
  dynamic root;
  dynamic squad; // to be shared between several tests

  test("assignment to add & replace data in Map & List", () {
    root = MapList();
    root.dico = {"US": "hello", "FR": "bonjour"};
    root.dico.add({"JP": "こんにちは"});
    assert(root.dico.FR == 'bonjour');
    root.dico.FR = "salut";
    assert(root.dico.FR == 'salut');
    assert(root.dico.length == 3);
    // change type of an entry
    root.dico.FR = ["bonjour", "salut", "helloxx"];
    assert(root.dico.length == 3);
    assert(root.dico.FR[1] == "salut");
    root.dico.FR[2] = "hello";
    assert(root.dico.FR.length == 3);
    assert(root.dico.FR[0] == "bonjour");
    assert(root.dico.FR[2] == "hello");

    root.script('dico.FR[2] = "comment va"');
    ;
    assert(root.dico.FR[2] == "comment va");
  });


  test("assignment on first level with code", () {
    squad = MapList();
    squad.name = "Super hero squad"; // String
    squad.homeTown = 'Metro City'; // String
    squad.formed = 2016; // int
    squad.active = true; // bool
    squad.score = 38.5; // double

    assert(squad.formed == 2016);
    assert(squad.active);
    assert(squad.score == 38.5);
  });

  test("create a List in a Map ", () {
    // continuing with previous data can't run alone
    assert(squad.formed == 2016);
    squad.members = [];
    // assign a full structure in one shot
    squad.members.add({
      "name": "Molecule Man",
      "age": 29,
      "secretIdentity": "Dan Jukes",
      "powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]
    });
    assert(squad.members[0].powers[1] == "Turning tiny");
  });

  test("assignement on first level with script", () {
    squad = MapList();
    squad.script('name = "Super hero squad"');
    squad.script("homeTown = 'Metro City'");
    squad.script('formed = 2016');
    squad.script('active = true');
    squad.script('score = 38.5');

    assert(squad.homeTown == "Metro City");
    assert(squad.formed == 2016);
    assert(squad.active);
    assert(squad.score == 38.5);
  });

  test("create a List in a Map with script  ", () {
    // warning : continuing with previous data can't run alone
    assert(squad.formed == 2016);
    squad.script('members = []');
    squad.script(
        'members.add({ "name": "Molecule Man","age": 29,"secretIdentity": "Dan Jukes",'
            '"powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]})');

    assert(squad.members[0].powers[1] == "Turning tiny");
  });

  test("deep changes mixed with script and code from file ", () {
    var testFile = path.join(
        Directory.current.path, 'test', 'models', 'json', 'super_heroes.json');
    var file = File(testFile);
    var jsonString = file.readAsStringSync();
    dynamic squad = MapList(jsonString);
    assert(squad.members[0].powers[1] == "Turning tiny");
    // change by code, test by code & script
    squad.members[0].powers[1] = "Turning heavy";
    squad.script('members[0].powers[1] = "Turning heavy"');
    assert(squad.members[0].powers[1] == "Turning heavy");
    // change by script, test by script and code
    squad.script('members[0].powers[1] = "Turning weird"');
    assert(squad.members[0].powers[1] == "Turning weird");
    assert(squad.script('members[0].powers[1]') == "Turning weird");
    });
}
