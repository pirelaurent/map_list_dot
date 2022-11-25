import 'package:map_list_dot/map_list_dot.dart';
import 'dart:collection';

/// extends MapList to wrap List methods
///
class MapListList extends MapList with IterableMixin {
  MapListList.json([dynamic json]) : super.json(json ??= []);

  @override
  int get length => json.length;

  /// change type to allow . downstream
  @override
  dynamic get last {
    var next = wrapped_json.last;
    if ((next is List) || (next is Map)) next = MapList(next);
    return next;
  }

  ///
  /// setter on a MapListList , set the wrapped data
  operator []=(Object key, dynamic value) {
    try {
      json[key] = value;
    } catch (e) {
      MapList.log.warning(
          '** on List : \"${MapList.lastInvocation} [$key] = \" : $e \n');
      return null;
    }
  }

  /// as an iterator will call the overriden [ ] method
  /// we can use the json iterator of underlying wrapped list
  /// it will goes from 0 to length -1 on json but the [ ] will return a MapList
  @override
  Iterator get iterator => MapListListIterator(wrapped_json);

  ///
  /// remove an entry by value in a list
  @override
  void remove(var aValue) {
    wrapped_json.remove(aValue);
  }

  ///
  /// getter on a List.
  /// to allow dot notation on the list, returns a MapList
  dynamic operator [](Object keyIndex) {
    try {
      var next = wrapped_json[keyIndex];
      MapList.lastInvocation = ''; // as ok, forget
      // wrap result in a MapList to allow next dot notation
      if ((next is List) || (next is Map)) next = MapList(next);

      // if a leaf, return a simple value
      return next;
    } catch (e) {
      var from = MapList.lastInvocation ?? 'at root: ';
      MapList.log.warning(
          'unknown accessor: .$from [$keyIndex] : null returned .\n Original message : $e ');
      return null;
    }
  }

  ///
  ///  Add a new element in a List
  dynamic add(dynamic something) {
    var toAdd = MapList.normaliseByJson(something);
    json.add(toAdd);
    return true;
  }

  /// method used whe a call by code
  /// similar exists at MapList level for interpreter
  /// done by hand to enforce type compatibility

  dynamic addAll(dynamic something) {
    if (something is MapListList) something = something.json;
    wrapped_json.addAll(something);
    return true;
  }

  ///toString is not inherited from MapList, maybe due to mixin
  @override
  String toString() {
    return json.toString();
  }
}

///
///  override Iterator to return MapList that allows .notation downstream
class MapListListIterator implements Iterator {
  var internal;

  MapListListIterator(var json) {
    internal = json.iterator;
  }

  @override
  dynamic get current {
    var result = internal.current;
    if ((result is List) || (result is Map)) result = MapList(result);
    return result;
  }

  @override
  bool moveNext() {
    return internal.moveNext();
  }
}
