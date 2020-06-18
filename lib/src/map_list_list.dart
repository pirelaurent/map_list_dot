
import 'package:map_list_dot/map_list_dot.dart';


/// extends MapList to wrap List methods
///
class MapListList extends MapList {
  MapListList.json(dynamic json) : super.json(json);

  get length => json.length;

  ///
  /// setter on a MapListList , set the wrapped data
  operator []=(Object key, dynamic value) {
    try {
      json[key] = value;
    } catch (e) {
      MapList.log.warning("** on List : \"${MapList.lastInvocation} [$key] = \" : $e \n");
      return null;
    }
  }

  ///
  /// remove an entry by value in a list
  @override
  void remove(var aValue) {
    wrapped_json.remove(aValue);
  }

  ///
  /// getter on a List.
  /// to allow dot notation on the list, returns a MapList
  operator [](Object keyIndex) {
    try {
      var next = wrapped_json[keyIndex];
      MapList.lastInvocation=""; // as ok, forget
      // wrap result in a MapList to allow next dot notation
      if (next is List || next is Map)
        return MapList(next); //, false
      // if a leaf, return a simple value
      else
        return next;
    } catch (e) {
      var from = MapList.lastInvocation ?? "at root: ";
      MapList.log.warning("unknown accessor: .$from [$keyIndex] : null returned .\n Original message : $e ");
      return null;
    }
  }

  ///
  ///  Add a new element in a List
  dynamic add(dynamic something) {
      var toAdd = MapList.normaliseByJson(something);
      this.json.add(toAdd);
      return true;
  }

  /// method used whe a call by code
  /// similar exists at MapList level for interpreter
  /// done by hand to enforce type compatibility

  dynamic addAll(dynamic something) {
    if (something is MapListList) something = something.json;
    something.forEach((value) {
      wrapped_json.add(value);
    });
    return true;
  }


}
