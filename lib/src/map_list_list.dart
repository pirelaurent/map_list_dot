import 'dart:collection';
import 'dart:convert';
import 'package:json_xpath/map_list_lib.dart';

/*
 a MapListList is no more a List as it don't realizes ListMixin

 */
class MapListList extends MapList {
  MapListList.json(dynamic json) : super.json(json);

  get length => wrapped_json.length;

  /*
   Setter in a list position.
   Must be an integer, but common operator is more general.
   */
  @override
  operator []=(Object key, dynamic value) {
    try {
      wrapped_json[key] = value;
    } catch (e) {
      //print("** On List : \"${MapList.lastInvocation} [$key] = \" : $e");
      return null;
    }
  }

  @override
  void remove(var aValue) {
    wrapped_json.remove(aValue);
  }


  /*
   getter in a list . can be an itermediate, so cast in MapList
   to allow further dot notation
   */
  @override
  operator [](Object keyIndex) {
    try {
      var next = wrapped_json[keyIndex];
      // wrap result in a MapList to allow next dot notation
      if (next is List || next is Map)
        return MapList(next,false);
      // if a leaf, return a simple value
      else
        return next;
    } catch (e) {
      //print("** On List: \"${MapList.lastInvocation} [$keyIndex]\" : $e");
      return null;
    }
  }

/*
 called directly by compiled code as MapListList mixin with list
 */
  @override
  void add(dynamic something) {
    something = MapList.normaliseByJson(something);
    this.wrapped_json.add(something);
  }


  @override
  void addAll(dynamic something) {
    //something = MapList.retype(something);
    this.wrapped_json.addAll(something);
  }
}
