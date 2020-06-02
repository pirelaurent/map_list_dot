import 'dart:collection';
import 'package:json_xpath/map_list_lib.dart';

/*
 Map wrapper
 */

class MapListMap extends MapList with MapMixin {
  MapListMap.json(dynamic json) : super.json(json);

  get keys => wrapped_json.keys;

//type 'double' is not a subtype of type 'String' of 'value'
  operator []=(Object key, dynamic value) => {wrapped_json[key] = value};

  operator [](Object key) {
    var next = wrapped_json[key];
    if (next is List || next is Map)
      return MapList(next);
    else
      return next;
  }

  void clear() {
    wrapped_json.clear();
  }

  void remove(var key) {
    wrapped_json.remove(key);
  }
}
