import 'package:json_xpath/src/map_list.dart';
import 'package:test/test.dart';
import 'dart:convert';
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
  dynamic root;
  dynamic squad; // to share between several tests
  test("assignement on first level with code", () {
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
    // continuing with previous data can't run alone
    assert(squad.formed == 2016);
    squad.script('members = []');
    squad.script(
        'members.add({ "name": "Molecule Man","age": 29,"secretIdentity": "Dan Jukes",'
            '"powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]})');

    assert(squad.members[0].powers[1] == "Turning tiny");
  });

}
