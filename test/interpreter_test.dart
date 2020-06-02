
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

  /*

   debug


 // assertShow(store.interpret("bikes[0].color"),"black");
 //print('ok for assertShow');
 // à pister
  //print(store.runtimeType);
  //print(store.bikes.runtimeType);

  store.bikes[0].color = "green";
 print('-------------- set color green by code ok ');
 noSuchMethod: Symbol("store"): []
noSuchMethod: Symbol("bikes"): []
noSuchMethod: Symbol("color="): [green]


  store.interpret("bikes[0].color= violet ");
  print(store.bikes[0].color);
  assertShow(store.bikes[0].color, "violet");
 //
 // print('ok for set by code');

  store.interpret("bikes[0].color = violet ");
  print(store.bikes[0].color);
  assertShow(store.bikes[0].color, "violet");
print('ok for violet');
*/

  test('basic verification on dot access ', () {
    assertShow(store.bikes[1].color, "grey");
    assertShow(store.book.length, 4);
    assertShow(store.book[0].isbn, "978-1-78899-879-6");
    assertShow(store.book[1].isbn, null);
  });

  test('basic verification on interpreted access ', () {
    assertShow(store.interpret("bikes[1].color"), "grey");
    assertShow(store.interpret("book[0].isbn"), "978-1-78899-879-6");
    assertShow(store.interpret("book[1].isbn"), null);
  });

  test('check length property', () {
    assertShow(store.interpret("book").length, 4);
    // check interpreted property length
    assertShow(store.interpret("book.length"), 4);
    assertShow(store.interpret("bikes.length"), 2);
    assertShow(store.interpret("bikes[1].length"), 2.2);
  });

  test('try assignements ', () {
    assertShow(store.interpret("bikes[0].color"),"black");

    store.bikes[0].color = "green";
    assertShow(store.interpret("bikes[0].color"),"green");
    store.interpret("bikes[0].color = blue ");
    print(store.bikes[0].color);
    assertShow(store.interpret("bikes[0].color"),"blue");

    assertShow(store.interpret("book[3].price"),23.42);
    store.interpret("book[3].price= 20.00 ");
    assertShow(store.interpret("book[3].price"),20.00);

  });

  test('try new values non existing', () {



    store.interpret("bikes[0].battery = true ");
    assertShow(store.interpret("bikes[0].battery"),true);
    store.interpret("bikes[1].battery = false ");
    assertShow(store.interpret("bikes[1].battery"),false);
    store.interpret("book").add({"category": "children", "name":"sleeping beauty"});
    assertShow(store.interpret("book[4].category"),"children");
  });





}