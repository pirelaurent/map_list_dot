import 'dart:io';
import 'package:json_xpath/JsonObject.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:test/test.dart';
import 'package:collection/collection.dart';
import 'package:json_xpath/json_xpath.dart';

void main() {
  var testFile =
      p.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  var jsonStore = json.decode(jsonString);
/*
You can explore directly this json by :
  assert(JsonXpath.xpathOnJson(jsonStore,"store.bicycle.color")=="red");

You can wrap it in a jsonObject to simplify access
  assert(aStore.xpath("store.bicycle.color")=="red");

 */
  JsonObject myStore = JsonObject.fromString(jsonString);
  Function eqList = const ListEquality().equals;

  JsonXpath.withNull = false;


 test("test single values",(){
   assert(myStore.xpath("store.bicycle.color")=="red");
   assert(myStore.xpath("store.book[1].author") == "Evelyn Waugh");
   assert(myStore.xpath("store.book[3].price") == 22.99);
 });

  test("test Lists ",(){
    assert(myStore.xpath("store.book").length==4);
    assert(myStore.xpath("store.book[2..3]").length == 2);
    assert(eqList(myStore.xpath("store.book[0..2].price"),[8.95, 12.99, 8.99]));
    assert(eqList(myStore.xpath("store.book.price"),[8.95, 12.99,8.99,22.99]));
  });

  test("test equivalence",(){
    assert(eqList(myStore.xpath("store.book"),myStore.xpath("store.book[]")));
    assert(eqList(myStore.xpath("store.book"),myStore.xpath("store.book[..]")));
    assert(eqList(myStore.xpath("store.book.author"),myStore.xpath("store.book[].author")));
    assert(eqList(myStore.xpath("store.book.price"),myStore.xpath("store.book[..].price")));
  });




  test("test wrong path ",()
  {
    assert(myStore.xpath("store.banana.price")== null);
    // wrong number
    assert(myStore.xpath("store.book[-1]")== null);
    // range over capacity
    assert(myStore.xpath("store.book[200]")== null);
    // first is over collection
    assert(myStore.xpath("store.book[8..15]")== null);

  });
  test("test with without null option",()
  {
    assert(myStore.xpath("store.book[1..2].cover") == null);
    assert(eqList(myStore.xpath("store.book.isbn"),["0-553-21311-3","0-395-19395-8"] ));
    // change option : null values are in the lists
    JsonXpath.withNull = true;
    assert(eqList(myStore.xpath("store.book[1..2].cover"),[null,null]));
    assert(eqList(myStore.xpath("store.book.isbn"),[null,null,"0-553-21311-3","0-395-19395-8"] ));
  });

  /*
   playing with Dart
   */
  Function f=JsonObject(jsonStore).xpath;
  assert(f("store.book[1].author") == "Evelyn Waugh");
}
