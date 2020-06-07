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
   tolerance . default : add doesn't exists for map
   */
  MapList add(var something){
    // add new entries to the current map
    if (something is Map){
      something.forEach((key, value) {
        this.wrapped_json[key]=value;
      });
      // to allow continuation
      return MapList(this);
    };

    /*
     adding anything else to a map is forbiddent
     */
    print('** error : trying to add non amp to current map $something to \n$this');
      return MapList(this);
    }
  }

