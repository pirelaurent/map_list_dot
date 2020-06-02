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
    //if (key is! int) );
    if (key is int) {
      wrapped_json[key] = value;
    } else {
      print('******** warning call List[] with a ${key.runtimeType} $key');
      // do nothing
    }
  }

  @override
  operator [](Object key) {
    if (key is int) {
      if ((key>=0)&&(key<wrapped_json.length))
      {
        var next = wrapped_json[key];
        // wrap result in a MapList to allow next dot notation
        if (next is List || next is Map)
          return MapList(next);
        // if a leaf, return a simple value
        else
          return next;
      }
    }
    // case nothing return : wrong rank or not an integer
    return MapListBlackHole.json("");
  }

  void add(dynamic value) {
    wrapped_json.add(value);
  }
}