import 'dart:convert';
import 'dart:io';
import 'package:json_xpath/JsonObject.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:test/test.dart';
import 'package:collection/collection.dart';


void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}

void main() {
  var testFile =
  p.join(Directory.current.path, 'test', 'models', 'json', 'person.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  var contact = JsonObject.fromString(jsonString);
 assert(contact.xpath('[1].name')=="Magellan");
 // compare array through string, otherwise see ListEquality().
  assertShow(contact.xpath('.name').toString(),"[Polo, Magellan]");
  assertShow(contact.xpath('[1].birthDate.day'),15);
  assertShow(contact.xpath('[].birthDate.month').toString(),"[9, 3]");
  assertShow(contact.xpath('[..].birthDate.month').toString(),"[9, 3]");
  assertShow(contact.xpath('.birthDate').toString(),"[{day: 15, month: 9, year: 1254}, {day: 15, month: 3, year: 1480}]");
  // here we go null Wrong !
  assertShow(contact.xpath('.birthDate.day').toString(),"pouet");





}
