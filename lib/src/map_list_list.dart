import 'dart:collection';

import 'package:map_list_dot/map_list_dot.dart';
import 'dart:io';

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
      print("** on List : \"${MapList.lastInvocation} [$key] = \" : $e \n");
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

      // wrap result in a MapList to allow next dot notation
      if (next is List || next is Map)
        return MapList(next, false);
      // if a leaf, return a simple value
      else
        return next;
    } catch (e) {
      var from = MapList.lastInvocation ?? "at root: ";
      stderr.write("** List error: \"$from [$keyIndex]\" : $e \n");
      return null;
    }
  }

  ///
  ///  Add a new element in a List
  void add(dynamic something) {
      var toAdd = MapList.normaliseByJson(something);
      this.json.add(toAdd);
  }

  ///
  /// add another List to this one
  void addAll(dynamic something) {
    this.json.addAll(something);
  }
}
