import 'package:json_xpath/src/map_list.dart';
import 'package:test/test.dart';
import 'dart:convert';

void trace(dynamic x) {
  print('$x : ${x.runtimeType}');
}

void main() {
  test(" test several input homogeneous  models ", () {
    var xInCode = {"age": 15, "weight": 65};
    //trace(xInCode); // _InternalLinkedHashMap<String, int>
    var xJson = json.decode('{"age": 15, "weight": 65}');
    //trace(xJson); // _InternalLinkedHashMap<String, dynamic>
    var xListInCode = [11, 12, 13];
    //trace(xListInCode); // List<int>
    xJson = json.decode('[11,12,13]');
    //trace(xJson); // List<dynamic>
  });

  test(" test several input heterogenous  models ", () {
    var xInCode = {"age": 15, "name":"toto", "active": true};
    //trace(xInCode);// _InternalLinkedHashMap<String, Object>
    var xJson = json.decode('{"age": 15, "name":"toto", "active": true}');
    //trace(xJson); //  _InternalLinkedHashMap<String, dynamic>
    var xListInCode = [11, "pouet", true];
    //trace(xListInCode); // List<Object>
    xJson = json.decode('[11, "pouet", true]');
    //trace(xJson); // List<dynamic>
  });

}
