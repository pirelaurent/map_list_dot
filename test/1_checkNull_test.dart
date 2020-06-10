import 'package:map_list_dot/map_list_dot_lib.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

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

  test("null test on path with code", () {
    assert(store.wrongName == null);
    //NoSuchMethodError: The getter 'someData' was called on null
    //assert(store.wrongName.someData==null);
    assert(store.wrongName?.someData == null);
  });

  test("null test on path with script ", () {
    assert(store.script("wrongName") == null);
    // if tagada is null, avoid following
    assert(store.script("wrongName?.someData") == null);
  });



  test("dataAccess with null test with code", () {
    assert(store.book[4] == null);
    //NoSuchMethodError: The getter 'author' was called on null.
    //assert(store.book[4].author==null);
    //
    assert(store.book[4]?.author == null);
    assert(store.bookList == null);
    assert(store.script("bookList") == null);

    // NoSuchMethodError: The method '[]' was called on null.
    // assert(store.bookList[0]==null);

    /* with nullable :
    assert(store.bookList?[0]==null);
Error: This requires the 'non-nullable' language feature to be enabled.
Try updating your pubspec.yaml to set the minimum SDK constraint to 2.9 or higher, and running 'pub get'.
     */
  });

  test("dataAccess with null test with script", () {

    assert(store.script("book[4]") == null);
    // assert(store.script("book[4].author") == null); //nok
    assert(store.script("book[4]?.author") == null);
    assert(store.bookList == null);
    assert(store.script("bookList") == null);
    assert(store.script("bookList[0]") == null);
    // available in script right now
    assertShow(store.script("bookList?[0]"), null);
    assertShow(store.script("bookList?[0].date"), null);
  });


}
