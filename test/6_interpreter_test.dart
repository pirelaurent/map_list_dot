import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/*
  if wrong test , show what was expected and what we got to facilitate debug
 */
void assertShow(var what, var expected) {
  assert(what == expected, "\nexpected: $expected got: $what");
}

void main() {
  var testFile =
      path.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  dynamic root = MapList(jsonString);
  dynamic store = root.store;

  test('basic verification on dot access ', () {
    assertShow(store.bikes[1].color, "grey");
    assertShow(store.book.length, 4);
    assertShow(store.book[0].isbn, "978-1-78899-879-6");
    assertShow(store.book[1].isbn, null);
  });

  test('basic verification on interpreted access ', () {
    assertShow(store.get("book[1].isbn"), null);
    assertShow(store.get("bikes[1].color"), "grey");
    assertShow(store.get("book[0].isbn"), "978-1-78899-879-6");
    assertShow(store.get("book[1].isbn"), null);
  });

  test('check length property', () {
    assertShow(store.get("book").length, 4);
    // check interpreted property length
    assertShow(store.get("book.length"), 4);
    assertShow(store.get("bikes.length"), 2);
    assertShow(store.get("bikes[1].price"), 2900);
    assert(store.get('bikes[1].length')== 5);
    assert(store.get('bikes[1]["length"]')== 2.2);
    assertShow(store.get("bikes[1]['length']"), 2.2);
  });

  test('try assignments ', () {
    assertShow(store.get("bikes[0].color"), "black");

    store.bikes[0].color = "green";
    assertShow(store.get("bikes[0].color"), "green");
    store.set("bikes[0].color = blue ");
    assertShow(store.get("bikes[0].color"), "blue");

    assertShow(store.get("book[3].price"), 23.42);
    store.exec("book[3].price= 20.00 ");
    assertShow(store.get("book[3].price"), 20.00);
  });

  test('try new values non existing', () {
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
    // strings in quotes
    store.set("bikes[1].color = 'violet'");
    assertShow(store.bikes[1].color, "violet");
    store.exec('bikes[1].color = "yellow"');
    assertShow(store.bikes[1].color, "yellow");
    store.exec("bikes[1].color = maroon");
    assertShow(store.bikes[1].color, "maroon");
  });

  test(' try item in string by error in interpreter ', () {
    dynamic book = MapList('{"name":"zaza", "friends": [{"name": "lulu" }]}');
    assert(book.friends[0].name == "lulu");
    assert(book.get('friends[0].name') == "lulu");
    assert(book.name == "zaza");
    book.set('"name"="zorro"');
    assert((book.name == "zorro") == false);
  });

  test('Access to a root List with only index ', () {
    dynamic list = MapList([]);
    list.add(15);
    list.set('addAll([1, 2, 3])');
    assert(list.get("length") == 4);
    assert(list[2] == 2);
    assert(list.get('[2]') == 2);
  });

  test(' access to current with empty or index only exec ', () {
    dynamic book = MapList(
        '{"name":"zaza", "friends": [{"name": "lulu" , "scores":[10,20,30]}]}');
    var interest = book.get('friends[0].scores');
    // by execor by code, we reach the same json
    assert(interest.get('[1]') == 20);
    interest.set('[1]=33');
    assert(interest[1] == 33);
    // but we cannot compare as they are two different Maplist (but with same pointers to json
    assert((interest.get().runtimeType == interest.runtimeType));
    assert(interest.get().json == interest.json);
    // verify change
    interest.set('[1]=33');
    assert(interest[1] == 33);

    assert((book.get().json) == book.json);
  });
}
