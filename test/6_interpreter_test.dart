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
    squad.set('name = "Super hero squad"');
    squad.set("homeTown = 'Metro City'");
    squad.set('formed = 2016');
    squad.set('active = true');
    squad.set('score = 38.5');

    assert(squad.homeTown == "Metro City");
    assert(squad.formed == 2016);
    assert(squad.active);
    assert(squad.score == 38.5);
  });


  test("extends a map to a map with interpreter ", () {
    // reset
    dynamic car = MapList();
    car.set('name = "Ford"');
    car.set('color = "blue"');
    assert(car.color == "blue");
    car.exec('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})');
    assert(car.length == 5);
  });

  test('Access to a root List with only the index ', () {
    dynamic list = MapList([]);
    list.add(15);
    list.exec('addAll([1, 2, 3])');
    assert(list.get("length") == 4);
    assert(list[2] == 2);
    assert(list.get('[2]') == 2);
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
    assertShow(store.get("book[1].isbn"), null);
    assertShow(store.get("bikes[1].color"), "grey");
    assertShow(store.get("book[0].isbn"), "978-1-78899-879-6");
    assertShow(store.get("book[1].isbn"), null);
  });

  test('check length property', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    // check interpreted property length
    assertShow(store.get("book.length"), 4);
    assertShow(store.get("bikes.length"), 2);
    // size of the list
    assert(store.get('bikes[1].length')== 5);
    //  the only way to get aproperty 'length' it is to use classical notation
    assert(store.get('bikes[1]["length"]')== 2.2);
    assertShow(store.get("bikes[1]['length']"), 2.2);
  });

  test('try assignments ', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    assertShow(store.get("bikes[0].color"), "black");

    store.bikes[0].color = "green";
    assertShow(store.get("bikes[0].color"), "green");
    store.set("bikes[0].color = blue ");
    assertShow(store.get("bikes[0].color"), "blue");

    assertShow(store.get("book[3].price"), 23.42);
    store.set("book[3].price = 20.00 ");
    assertShow(store.get("book[3].price"), 20.00);
  });

  test('try new values non existing', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    store.set("bikes[0].battery = true ");
    assertShow(store.get("bikes[0].battery"), true);
    store.set("bikes[1].battery = false ");
    assertShow(store.get("bikes[1].battery"), false);
    store
        .get("book")
        .add({"category": "children", "name": "sleeping beauty"});
    assertShow(store.get("book[4].category"), "children");
  });

  test('try Types in string ', () {
    dynamic root = MapList(jsonStringStore);
    // get a lower entry point direclty on store
    dynamic store = root.store;
    // strings in quotes
    store.set("bikes[1].color = 'violet'");
    assertShow(store.bikes[1].color, "violet");
    store.set('bikes[1].color = "yellow"');
    assertShow(store.bikes[1].color, "yellow");
    store.set("bikes[1].color = maroon");
    assertShow(store.bikes[1].color, "maroon");
  });

  test(' try item in string with  error in interpreter ', () {
    dynamic book = MapList('{"name":"zaza", "friends": [{"name": "lulu" }]}');
    assert(book.friends[0].name == "lulu");
    assert(book.get('friends[0].name') == "lulu");
    assert(book.name == "zaza");
    book.set('"name"="zorro"');
    assert((book.name == "zorro") == false);
  });



  test(' access to current with empty or index only  ', () {
    // create with a string json-like
    dynamic book = MapList(
        '{"name":"zaza", "friends": [{"name": "lulu" , "scores":[10,20,30]}]}');
    // use a relay
    // Here var : return type will be a MapList, so interest becomes one
    // (better to use dynamic as a rule of thumb)
    var interest = book.get('friends[0].scores');
    assert(interest.get('[1]') == 20);
    interest.set('[1]=33');
    assert(interest[1] == 33);
    // interest.get() with no path returns itself
    // Caution don't compare the wew result and a previous one :
    // They are two different Maplist, but with same pointers to json
    assert((interest.get() != interest));
    // verifying pointer
    assert((interest.get().runtimeType == interest.runtimeType));
    assert(interest.get().json == interest.json);
    // verify changes affects both
    interest.set('[1]=33');
    assert(interest[1] == 33);

  });
}
