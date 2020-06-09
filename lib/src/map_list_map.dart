import 'dart:collection';
import 'package:json_xpath/map_list_lib.dart';

/*
 Map wrapper . no Mixin
 */

class MapListMap extends MapList {//with MapMixin {
  MapListMap.json(dynamic json) : super.json(json);


  get length => wrapped_json.length;
  get keys => wrapped_json.keys;


  operator []=(dynamic key, dynamic value) {
  wrapped_json[key] = value;
  }
/*
 next is a json part
 */
  operator [](Object key) {
    var next = wrapped_json[key];
    if (next is List || next is Map)
      return MapList(next,false);
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
   In fact it's addALL filtered in MapList level
   cannot override standard addALl
   */
  MapList add(var something){
    // add new raw entries to the current map
    if (something is Map){
      wrapped_json.addAll(something);
      // to allow continuation
      return MapList(this);
    };
    /*
     adding anything else to a map is forbidden
     */
    print('** error : trying to add non amp to current map $something to \n$this');
      return MapList(this);
    }

  @override
  dynamic addAll(dynamic something) {
      // add new entries to the current map
      if (something is Map) {
        this.wrapped_json.addAll(something);
        // to allow continuation
        return MapList(this);
      };
      print('** trying to addAll to a Map something else than another map');
    }


  }

