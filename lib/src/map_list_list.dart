import 'dart:collection';
import 'dart:convert';
import 'package:json_xpath/map_list_lib.dart';

/*
 a MapListList is a List as it realizes ListMixin

 */
class MapListList extends MapList with ListMixin {
  MapListList.json(dynamic json) : super.json(json);

  get length => wrapped_json.length;

  set length(int len) {
    wrapped_json.length = len;
  }

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
  operator [](Object keyIndex) {
    try {
      var next = wrapped_json[keyIndex];
      // wrap result in a MapList to allow next dot notation
      if (next is List || next is Map)
        return MapList(next);
      // if a leaf, return a simple value
      else
        return next;
    } catch (e) {
      //print("** On List: \"${MapList.lastInvocation} [$keyIndex]\" : $e");
      return null;
    }
  }

/*
 When call directly from code :
 in case of List or Map, the something can be a restricted type
 (aka a Lis<int> or a Map<String, String>
 So we enlarge it with retype.

 */
  void add(dynamic something) {
    something = retype(something);
    wrapped_json.add(something);
  }
}
