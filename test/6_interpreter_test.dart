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

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  var testFile =
      path.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonStringStore = file.readAsStringSync();
  //

  test("assignement on first level with script", () {
    dynamic squad;
    squad = MapList();
    squad.exec('name = "Super hero squad"');
    squad.exec("homeTown = 'Metro City'");
    squad.exec('formed = 2016');
    squad.exec('active = true');
    squad.exec('score = 38.5');
print(squad);
    assert(squad.homeTown == "Metro City");
    assert(squad.formed == 2016);
    assert(squad.active);
    assert(squad.score == 38.5);
  });

  test("extends a map to a map with interpreter ", () {
    // reset
    dynamic car = MapList();
    car.exec('name = "Ford"');
    car.exec('color = "blue"');
    assert(car.color == "blue");
    car.exec('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})');
    assert(car.length == 5);
  });

  test('Access to a root List with only the index ', () {
    dynamic list = MapList([]);
    list.add(15);
    list.exec('addAll([1, 2, 3])');
    assert(list.exec("length") == 4);
    assert(list[2] == 2);
    assert(list.exec('[2]') == 2);
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
    assertShow(store.exec("book[1].isbn"), null);
    assertShow(store.exec("bikes[1].color"), "grey");
    assertShow(store.exec("book[0].isbn"), "978-1-78899-879-6");
    assertShow(store.exec("book[1].isbn"), null);
  });

  test('check length property', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    // check interpreted property length
    assertShow(store.exec("book.length"), 4);
    assertShow(store.exec("bikes.length"), 2);
    // size of the list
    assert(store.exec('bikes[1].length') == 5);
    //  the only way to get aproperty 'length' it is to use classical notation
    assert(store.exec('bikes[1]["length"]') == 2.2);
    assertShow(store.exec("bikes[1]['length']"), 2.2);
  });

  test('try assignments ', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    assertShow(store.exec("bikes[0].color"), "black");

    store.bikes[0].color = "green";
    assertShow(store.exec("bikes[0].color"), "green");
    store.exec("bikes[0].color = blue ");
    assertShow(store.exec("bikes[0].color"), "blue");

    assertShow(store.exec("book[3].price"), 23.42);
    store.exec("book[3].price = 20.00 ");
    assertShow(store.exec("book[3].price"), 20.00);
  });

  test('try new values non existing', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    store.exec("bikes[0].battery = true ");
    assertShow(store.exec("bikes[0].battery"), true);
    store.exec("bikes[1].battery = false ");
    assertShow(store.exec("bikes[1].battery"), false);
    store.exec("book").add({"category": "children", "name": "sleeping beauty"});
    assertShow(store.exec("book[4].category"), "children");
  });

  test('try Types in string ', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    // strings in quotes
    store.exec("bikes[1].color = 'violet'");
    assertShow(store.bikes[1].color, "violet");
    store.exec('bikes[1].color = "yellow"');
    assertShow(store.bikes[1].color, "yellow");
    store.exec("bikes[1].color = maroon");
    assertShow(store.bikes[1].color, "maroon");
  });

  test(' try item in string with  error in interpreter ', () {
    dynamic book = MapList('{"name":"zaza", "friends": [{"name": "lulu" }]}');
    assert(book.friends[0].name == "lulu");
    assert(book.exec('friends[0].name') == "lulu");
    assert(book.name == "zaza");
    print(book.exec('"name"'));
    print('this test will generate a warning : ("name" ="zorro" );');
    book.exec('"name" ="zorro"');
    assert((book.name == "zorro") == false);
  });

  test(' access to current with empty or index only  ', () {
    // create with a string json-like
    dynamic book = MapList(
        '{"name":"zaza", "friends": [{"name": "lulu" , "scores":[10,20,30]}]}');
    // use a relay
    // Here var : return type will be a MapList, so interest becomes one
    // (better to use dynamic as a rule of thumb)
    var interest = book.exec('friends[0].scores');
    assert(interest.exec('[1]') == 20);
    interest.exec('[1]=33');
    assert(interest[1] == 33);
    // interest.exec() with no path returns itself
    // Caution don't compare the wew result and a previous one :
    // They are two different Maplist, but with same pointers to json
    assert((interest.exec() != interest));
    // verifying pointer
    assert((interest.exec().runtimeType == interest.runtimeType));
    assert(interest.exec().json == interest.json);
    // verify changes affects both
    interest.exec('[1]=33');
    assert(interest[1] == 33);
  });

  test('add and adAll in interpreter', () {
    var root = MapList();
    root.exec('contacts = []');
    root.exec('contacts.add({"name":"polo"})');

    assert(root.exec('contacts.length') == 1);
    // the following will fail on a wrong json
    root.exec(
        'contacts[last].addAll({"firstName" : "marco", "birthDate" = "15/09/1254"})');
    // this one is correct
    root.exec(
        'contacts[last].addAll({"firstName" : "marco", "birthDate" : "15/09/1254"})');
    print(root);
    //assert(root.exec('contacts[last].length') == 3);
    assert(root.exec('contacts.last.length') == 3);
  });

  test ('combine .last and .length',(){
    var root = MapList(["AA", "BB","CC", 12]);
    assert(root.exec('last') ==12);
    root = MapList(["AA", "BB","CC", [11,12,13]]);
    assert(root.exec('last.length') ==3);



  });

}
