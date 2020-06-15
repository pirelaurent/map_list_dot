import 'dart:io';

import 'package:map_list_dot/map_list_dot_lib.dart';

/// extends MapList to offer Map methods

class MapListMap extends MapList {
  //with MapMixin {
  MapListMap.json(dynamic json) : super.json(json);

  get length => json.length;

  get keys => json.keys;

  operator []=(dynamic key, dynamic value) {
    json[key] = value;
  }

/*
 next is a json part
 */
  operator [](Object key) {
    var next = json[key];
    if (next is List || next is Map)
      return MapList(next, false);
    else
      return next;
  }

  void clear() {
    json.clear();
  }

  @override
  void remove(var key) {
    json.remove(key);
  }

  @override
  bool get isEmpty {
    return (keys.length == 0);
  }

  @override
  bool containsKey(String aKey)
  {
    return wrapped_json.containsKey(aKey);
  }

  /*
   In fact it's addALL filtered in MapList level
   cannot override standard addALl
   */
  MapList add(var something) {
    // add new raw entries to the current map
    if (something is Map) {
      json.addAll(something);
      // to allow continuation
      return MapList(this);
    }
    ;
    /*
     adding anything else to a map is forbidden
     */
    print(
        '** error : trying to add non amp to current map $something to \n$this');
    return MapList(this);
  }

  dynamic addAll(dynamic something) {
    // add new entries to the current map
    if (something is Map) {
      this.json.addAll(something);
      // to allow continuation
      return MapList(this);
    }
    ;
    stderr.write(
        '** trying to addAll to a Map something else than another map \n $something');
  }
}
