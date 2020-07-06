import 'package:map_list_dot/map_list_dot.dart';

/// extends MapList to offer Map methods

class MapListMap extends MapList {
  MapListMap.json(dynamic json) : super.json(json);
  // default constructor
  MapListMap([dynamic json]) : super.json(json ??= {});

  int get length => json.length;

  Iterable get keys => json.keys;

  operator []=(dynamic key, dynamic value) {
    json[key] = value;
  }

  ///
  /// Allows to iterate on keys on a MapListMap
  /// f is injected by caller

  void forEach(dynamic Function(String key, dynamic value) f) {
    for (var key in wrapped_json.keys) {
      var value = wrapped_json[key];
      if ((value is Map) || (value is List)) value = MapList(value);
      f(key, value);
    }
  }

/*
 next is a json part
 */
  dynamic operator [](Object key) {
    var next = json[key];
    if ((next is List) || (next is Map)) {
      next = MapList(next);
    }
    return next;
  }

  @override
  void clear() {
    json.clear();
  }

  @override
  void remove(var key) {
    json.remove(key);
  }

  @override
  bool get isEmpty {
    return (keys.isEmpty);
  }

  @override
  bool get isNotEmpty {
    return (keys.isNotEmpty);
  }

  @override
  bool containsKey(String aKey) {
    return wrapped_json.containsKey(aKey);
  }

  /// method used whe a call by code
  /// similar exists at MapList level for interpreter
  /// done by hand as json could be dyn,dyn and we are String,dyn
  ///
  dynamic addAll(dynamic something) {
    // add new entries to the current map
    if (something is MapListMap) something = something.json;
    if (something is Map) {
      something.forEach((key, value) {
        wrapped_json[key] = value;
      });

      return true;
    }
    // could be an error in rhs
    if (something == null) return true;
    MapList.log.warning(
        '** trying to addAll to a Map something else than another map \n $something');
    return false;
  }
}
