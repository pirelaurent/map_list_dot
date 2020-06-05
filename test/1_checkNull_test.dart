import 'package:json_xpath/src/map_list.dart';
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

  test("null test on path ", () {
    assert(store.wrongName == null);
    //NoSuchMethodError: The getter 'someData' was called on null
    //assert(store.wrongName.someData==null);
    assert(store.wrongName?.someData == null);
    assert(store.script("wrongName") == null);
    // if tagada is null, avoid following
    assert(store.script("wrongName?.someData") == null);
  });

  test("dataAccess with null test ", () {
    assert(store.book[4] == null);
    //NoSuchMethodError: The getter 'author' was called on null.
    //assert(store.book[4].author==null);
    //
    assert(store.book[4]?.author == null);
    assert(store.script("book[4]") == null);
    // assert(store.script("book[4].author") == null); //nok
    assert(store.script("book[4]?.author") == null);
    //
    assert(store.bookList == null);
    assert(store.script("bookList") == null);

    // not available in code : assert(store.bookList[0]==null);
    assert(store.script("bookList[0]") == null);
    // assert (store.bookList[0] == null) : NoSuchMethodError: The method '[]' was called on null.

    /* with nullable :
    assert(store.bookList?[0]==null);
Error: This requires the 'non-nullable' language feature to be enabled.
Try updating your pubspec.yaml to set the minimum SDK constraint to 2.9 or higher, and running 'pub get'.
     */
    assertShow(store.script("bookList?[0]"), null);
    assertShow(store.script("bookList?[0].date"), null);
  });
}
