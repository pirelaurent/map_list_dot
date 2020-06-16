import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void assertShow(var what, var expected) {
  assert(what == expected, "\nexpected: $expected got: $what");
}

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  // ---------------- use store json file
  var testFile =
      path.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  dynamic root = MapList(jsonString);
  dynamic store = root.store;

  print('------- these tests will generate normal Warnings for demonstration purpose ----');


  test("null test on path with code", () {
    assert(store.wrongName == null);
    //assert(store.wrongName.someData==null);
    //-> NoSuchMethodError: The getter 'someData' was called on null
    assert(store.wrongName?.someData == null);
    //ok
  });

  test("null test on path with interpreter", () {
    assert(store.get("wrongName") == null);
    // interpreter won't fail but returns null
    assert(store.get("wrongName.someData") == null);
    assert(store.get("wrongName?.someData") == null);
  });

  test("dataAccess with null test with code", () {
    assert(store.book[4] == null);
    //NoSuchMethodError: The getter 'author' was called on null.
    //assert(store.book[4].author==null);
    //
    assert(store.book[4]?.author == null);
    assert(store.bookList == null);
    assert(store.get("bookList") == null);

    // NoSuchMethodError: The method '[]' was called on null.
    // assert(store.bookList[0]==null);

    /* with nullable :
    assert(store.bookList?[0]==null);
    Error: This requires the 'non-nullable' language feature to be enabled.
    Try updating your pubspec.yaml to set the minimum SDK constraint to 2.9 or higher, and running 'pub get'.
     */
  });

  test("dataAccess with null test with interpreter", () {
    assert(store.get("book[4]") == null);
    assert(store.get("book[4].author") == null);
    //-> Warning ** unexisting book[4].author in interpreter . null returned
    assert(store.get("book[4]?.author") == null);
    assert(store.bookList == null);
    assert(store.get("bookList") == null);
    assert(store.get("bookList[0]") == null);
    // available in execright now
    assertShow(store.get("bookList?[0]"), null);
    assertShow(store.get("bookList?[0].date"), null);
  });
}
