import 'dart:collection';
import 'dart:convert';
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
    try {
      wrapped_json[key] = value;
    } catch (e) {
      //print("** On List : \"${MapList.lastInvocation} [$key] = \" : $e");
      return null;
    }
  }

  @override
  operator [](Object keyIndex) {

    try {
      var next = wrapped_json[keyIndex];
      // wrap result in a MapList to allow next dot notation
      if (next is List || next is Map)
        return MapList(next);
      // if a leaf, return a simple value
      else
        return next;
    } catch (e) {
      //print("** On List: \"${MapList.lastInvocation} [$keyIndex]\" : $e");
      return  null;
    }
  }

/*
 if add comes from interpreter, decode the json
 if add comes from code, Dart has already done the job
 but if data are homeneous, json can create a map <String, int>
 like with {elapsed_time: 30, temperature: 18}// _InternalLinkedHashMap<String, int>
 this avoid to add dynamicaly other types, o we convert

 */
  void add(dynamic something) {
    print('in List : add $something');



    // @todo securise by try catch and allow simple lists of Strings
    if (something is String) {
      // is it json candidate
      var found = MapList.reg_mapList.firstMatch(something);
      if (found != null) something = json.decode(something);
      // either decoded json, either pure String
    };

    if (something is Map) {
      if(!(something.runtimeType is Map<dynamic, dynamic>));
      print('on a trouvé un bad Map dans List ${something.runtimeType} $something');
      Map <dynamic, dynamic> map = Map.fromEntries(something.entries);
      something = map;
    }
     print('PLA2 ${wrapped_json.runtimeType}');
      wrapped_json.add(something);
    }
  }
