import 'dart:collection';
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
      print("** On List : \"${MapList.lastInvocation} [$key] = \" : $e");
     }
  }

  @override
  operator [](Object key) {
    try {
      var next = wrapped_json[key];
      // wrap result in a MapList to allow next dot notation
      if (next is List || next is Map)
        return MapList(next);
      // if a leaf, return a simple value
      else
        return next;
    } catch (e) {
      print("** On Map: \"${MapList.lastInvocation} [$key]\" : $e");
      return  null;
    }
  }

  void add(dynamic value) {
    wrapped_json.add(value);
  }
}
