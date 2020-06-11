
import 'package:test/test.dart';
import 'dart:convert';

void trace(String help,dynamic x) {
  print(' $x :$help: ${x.runtimeType}');
}

void main() {
  print('----------- checking standard types before and after json.decode ');
  test(" test several input homogeneous  models ", () {
    var xInCode = {"age": 15, "weight": 65};
    trace('before',xInCode); // _InternalLinkedHashMap<String, int>
    var xJson = json.decode('{"age": 15, "weight": 65}');
    trace('after ',xJson); // _InternalLinkedHashMap<String, dynamic>
    var xListInCode = [11, 12, 13];
    trace('before',xListInCode); // List<int>
    xJson = json.decode('[11,12,13]');
    trace('after ',xJson); // List<dynamic>
  });

  test(" test several input heterogenous  models ", () {
    var xInCode = {"age": 15, "name":"toto", "active": true};
    trace('before',xInCode);// _InternalLinkedHashMap<String, Object>
    var xJson = json.decode('{"age": 15, "name":"toto", "active": true}');
    trace('after ',xJson); //  _InternalLinkedHashMap<String, dynamic>
    var xListInCode = [11, "pouet", true];
    trace('before',xListInCode); // List<Object>
    xJson = json.decode('[11, "pouet", true]');
    trace('after ',xJson); // List<dynamic>
  });

}
