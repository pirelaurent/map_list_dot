import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

/*
  if wrong test , show what was expected and what we got to facilitate debug
 */
void assertShow(var what, var expected) {
  assert(what == expected, "\nexpected: $expected got: $what");
}

void setLog() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

void main() {
  setLog();
/*
 a json is taken in a resource file
 */
  var testFile =
      path.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonStringStore = file.readAsStringSync();
  //
  test('basic assignments sample for readme', () {
    dynamic squad = MapList(); // will create a default Map
    squad.eval('name = "Super hero squad"'); // add a String data
    squad.eval('homeTown = "Metro City"'); // another
    squad.eval('formed = 2016'); // add an int
    squad.eval('active = true'); // add a bool
    squad.eval('score = 38.5'); // add a double
    squad.eval('overhauls = ["2008/04/10", "2102/05/01", "2016/04/17"]');
    assert(squad.homeTown == "Metro City");
    assert(squad.formed == 2016);
    assert(squad.active);
    assert(squad.score == 38.5);
  });

  test("extends a map to a map with interpreter ", () {
    // reset
    dynamic car = MapList();
    car.eval('name = "Ford"');
    car.eval('color = "blue"');
    assert(car.color == "blue");
    car.eval('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})');
    assert(car.length == 5);
  });

  test('Access to a root List with only the index ', () {
    dynamic list = MapList([]);
    list.add(15);
    list.eval('addAll([1, 2, 3])');
    assert(list.eval('length') == 4);
    assert(list[2] == 2);
    assert(list.eval('[2]') == 2);
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

  test('basic verification on interpreted access ', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    assertShow(store.eval("book[1].isbn"), null);
    assertShow(store.eval("bikes[1].color"), "grey");
    assertShow(store.eval("book[0].isbn"), "978-1-78899-879-6");
    assertShow(store.eval("book[1].isbn"), null);
  });

  test('using length property and length key in a map ', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    // check interpreted property length
    assertShow(store.eval("book.length"), 4);
    assertShow(store.eval("bikes.length"), 2);
    // size of the list
    assert(store.eval('bikes[1].length') == 5);
    //  the only way to get a property 'length' it is to use classical notation
    assert(store.eval('bikes[1]["length"]') == 2.2);
    assertShow(store.eval("bikes[1]['length']"), 2.2);
  });

  test('try assignments to change data', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    assertShow(store.eval("bikes[0].color"), "black");
    store.bikes[0].color = "green";
    assertShow(store.eval("bikes[0].color"), "green");
    assertShow(store.eval("book[3].price"), 23.42);
    store.eval("book[3].price = 20.00 ");
    assertShow(store.eval("book[3].price"), 20.00);
  });

  test('try new values non existing', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    store.eval("bikes[0].battery = true ");
    assertShow(store.eval("bikes[0].battery"), true);
    // not yet created for bikes 1
    assert(store.eval("bikes[1].battery") == null);
    // create the entry
    store.eval("bikes[1].battery = false ");
    assertShow(store.eval("bikes[1].battery"), false);
    store.eval("book").add({"category": "children", "name": "sleeping beauty"});
    assertShow(store.eval("book[4].category"), "children");
  });

  test(' try item in string with warning or error in interpreter ', () {
    setLog();
    dynamic book = MapList();
    book.eval('addAll({ "name":"zaza", "friends": [{"name": "lulu" }]})');
    // book.eval('addAll({"name":"zaza", "friends": [{"name": "lulu" }]}'); // missing right parenthesis generate a log
    assert(book.eval('friends[0].name') == "lulu");
    assert(book.name == "zaza");
    print(
        '----- this test will generate a warning : ("name" ="zorro" ) but do the job ----- ');
    book.eval('"name" = "zorro"');
    assert((book.name == "zorro") == true);
  });

  test(' check relay pointers  ', () {
    // create with a string json-like
    dynamic book = MapList(
        '{"name":"zaza", "friends": [{"name": "lulu" , "scores":[10,20,30]}]}');
    // use a relay
    var interest = book.eval('friends[0].scores');
    assert(interest.eval('[1]') == 20);
    // verify that a change affects both
    interest.eval('[1]=33');
    assert(interest[1] == 33);
    /*
    interest.eval() with no path returns a Maplist with same root.
    It is a different Maplist, but with same pointers to json
    */
    assert((interest.eval() != interest));
    // verifying pointers and types
    assert(interest.eval().json == interest.json);
    assert((interest.eval().runtimeType == interest.runtimeType));
  });

  test('add and adAll in interpreter', () {
    dynamic root = MapList();
    root.eval('contacts = []');
    root.eval('contacts.add({"name":"polo"})');

    assert(root.eval('contacts.length') == 1);
    // the following will fail on a wrong json
    print('----- this test will generate a warning about json ----');
    root.contacts.last.addAll(null);
    root.eval(
        'contacts.last.addAll({"firstName" : "marco", "birthDate" = "15/09/1254"})');
    // this one is correct
    root.eval(
        'contacts.last.addAll({"firstName" : "marco", "birthDate" : "15/09/1254"})');
    //assert(root.eval('contacts[last].length') == 3);
    assert(root.eval('contacts.last.length') == 3);
  });

  test('combine .last and .length', () {
    dynamic root = MapList(["AA", "BB", "CC", 12]);
    assert(root.eval('last') == 12);
    root = MapList([
      "AA",
      "BB",
      "CC",
      [11, 12, 13]
    ]);
    assert(root.eval('last.length') == 3);
  });
}
