import 'dart:collection';
import 'package:json_xpath/map_list_lib.dart';

/*
 Map wrapper
 */

class MapListMap extends MapList with MapMixin {
  MapListMap.json(dynamic json) : super.json(json);

  get keys => wrapped_json.keys;


  operator []=(dynamic key, dynamic value) {

  wrapped_json[key] = value;
  }

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

  @override
  void remove(var key) {
    wrapped_json.remove(key);
  }

  @override
  bool get isEmpty {
    return (keys.length == 0);
  }

  /*
   tolerance
   */
  MapList add(var something){
    // add a Map to a List
    if (something is Map){
      print('found bad Map in Map ${something.runtimeType} $something');
      something.forEach((key, value) {
        this.wrapped_json[key]=value;
      });
      // to allow continuation
      return MapList(this);
    }
    //add a List to a List
    if (something is List){
      return MapList(this);
    }
  }
}
