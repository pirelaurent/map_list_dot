import 'dart:io';
import 'package:json_xpath/JsonObject.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:test/test.dart';
import 'package:json_xpath/json_xpath.dart';

void main() {
  var testFile =
      p.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  var jsonStore = json.decode(jsonString);

  assert(JsonXpath.xpathOnJson(jsonStore,"store.bicycle.color")=="red");
  assert(JsonXpath.xpathOnJson(jsonStore,"store.book").length==4);
  assert(JsonXpath.xpathOnJson(jsonStore,"store.book[1].author") == "Evelyn Waugh");
  // now make a simpleObject
 JsonObject aStore = JsonObject.fromString(jsonString);
  assert(aStore.xpath("store.bicycle.color")=="red");
  assert(aStore.xpath("store.book").length==4);
  assert(aStore.xpath("store.book[1].author") == "Evelyn Waugh");

}
