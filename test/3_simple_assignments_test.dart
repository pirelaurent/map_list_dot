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
  var numbersName = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine"
  ];

  test("assignement on first level created with script", () {
    dynamic squad;
    squad = MapList();
    squad.eval("homeTown = 'Metro City'");
    squad.eval('name = "Super hero squad"');
    squad.eval('formed = 2016');
    squad.eval('active = true');
    squad.eval('score = 38.5');

    assert(squad.homeTown == "Metro City");
    assert(squad.formed == 2016);
    assert(squad.active);
    assert(squad.score == 38.5);
  });

  test("assignment to add & replace data in MapList", () {
    // as we plan to have heterogeneous data, we specify dynamic for dico
    root = MapList({
      "dico": <String, dynamic>{
        "hello": {"US": "Hi", "FR": "bonjour"}
      }
    });
    assert(root.dico.hello.US == "Hi");
    // we can add an entry  List as we have precise dynamic
    root.dico.numbers = {"US": numbersName};
    assert(root.dico.numbers.US[3] == "three");

    // if we create the MapList with a String, dynamic in ensured
    root = MapList('{"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }}');
    assert(root.dico.hello.US == "Hi");
    root.dico.numbers = {"US": numbersName};
    assert(root.dico.numbers.US[3] == "three");
    // we can use relays
    var numbers = root.dico.numbers;
    var US_numbers = numbers.US;
    US_numbers.add("ten");
    assert(root.dico.numbers.US[10] == 'ten');
  });

  test(" to add & replace UTF8 data in MapList ", () {
    // check creation
    // as we plan to add heterogeneous data in that map we cast
    root = MapList();
    root.dico = <String, dynamic>{"US": "hello", "FR": "bonjour"};
    root.dico.addAll({"JP": "こんにちは"});
    assert(root.dico.FR == 'bonjour');
    assert(root.dico.JP == 'こんにちは');
    // check modification
    root.dico.FR = "salut";
    assert(root.dico.FR == 'salut');
    //check length
    assert(root.dico.length == 3);
    assert(root.eval('dico.length') == 3);
    // change type of an entry
    root.dico.FR = ["bonjour", "salut", "hello"];
    assert(root.dico.length == 3);
    assert(root.dico.FR.length == 3);
    assert(root.eval('dico.FR.length') == 3);
    // change by code, verify by interpreter
    assert(root.dico.FR[0] == "bonjour");
    assert(root.eval('dico.FR[1]') == "salut");
    //change by code, verify by interpreter
    root.dico.FR[2] = "hello";
    assert(root.eval('dico.FR[2]') == "hello");
    // change by interpreter. verify by code
    root.eval('dico.FR[2] = "comment va"');
    assert(root.dico.FR[2] == "comment va");
  });

  test("deep changes mixed with interpreter and code from file ", () {
    var testFile = path.join(
        Directory.current.path, 'models', 'json', 'super_heroes.json');
    var file = File(testFile);
    var jsonString = file.readAsStringSync();
    dynamic squad = MapList(jsonString);

    assert(squad.members[0].powers[1] == "Turning tiny");
    assert(squad.eval('members[0].powers[1]') == "Turning tiny");

    // change by code, test by code & script
    squad.members[0].powers[1] = "Turning heavy";
    assert(squad.eval('members[0].powers[1]') == "Turning heavy");
    // change by script, test by eval and code
    squad.eval('members[0].powers[1] = "Turning weird"');
    assert(squad.members[0].powers[1] == "Turning weird");
    assert(squad.eval('members[0].powers[1]') == "Turning weird");
  });
}
