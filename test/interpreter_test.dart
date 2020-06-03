
import 'package:json_xpath/src/map_list.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
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
    assertShow(store.book[1].isbn.isEmpty, true);
  });

  test('basic verification on interpreted access ', () {
    assertShow(store.path("bikes[1].color"), "grey");
    assertShow(store.path("book[0].isbn"), "978-1-78899-879-6");
    assertShow(store.path("book[1].isbn.isEmpty"), true);
  });

  test('check length property', () {
    assertShow(store.path("book").length, 4);
    // check interpreted property length
    assertShow(store.path("book.length"), 4);
    assertShow(store.path("bikes.length"), 2);
    assertShow(store.path("bikes[1].length"), 2.2);
  });

  test('try assignments ', () {
    assertShow(store.path("bikes[0].color"), "black");

    store.bikes[0].color = "green";
    assertShow(store.path("bikes[0].color"), "green");
    store.path("bikes[0].color = blue ");
    assertShow(store.path("bikes[0].color"), "blue");

    assertShow(store.path("book[3].price"), 23.42);
    store.path("book[3].price= 20.00 ");
    assertShow(store.path("book[3].price"), 20.00);
  });

  test('try new values non existing', () {
    store.path("bikes[0].battery = true ");
    assertShow(store.path("bikes[0].battery"), true);
    store.path("bikes[1].battery = false ");
    assertShow(store.path("bikes[1].battery"), false);
    store.path("book").add(
        {"category": "children", "name": "sleeping beauty"});
    assertShow(store.path("book[4].category"), "children");

  });

  test('try Types in string ', () {
    // strings in quotes
    store.path("bikes[1].color = 'violet'");
    assertShow(store.bikes[1].color, "violet");
    store.path('bikes[1].color = "yellow"');
    assertShow(store.bikes[1].color, "yellow");
    store.path("bikes[1].color = maroon");
    assertShow(store.bikes[1].color, "maroon");
  });


}
