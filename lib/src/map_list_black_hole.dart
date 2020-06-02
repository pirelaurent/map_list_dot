import 'dart:collection';
import 'package:json_xpath/map_list_lib.dart';
/*
 this class is to avoid a crash if an intermediate comes to null .
 ex: a mymap["key"].following  will crash if myMap is null
 e:  a myList[12].following will crash if myList is null or 12 is out of range

 In these case, map_list will return a blackHole which will allow to continue
 and allways return another blackhole up to the end.

 The runtimeType of blackHole is forced to Null
 */

class MapListBlackHole extends MapList{
  MapListBlackHole.json(dynamic json) : super.json(json){
   print("construction of a blackHole");

  }

  operator [](Object key){
    return this;
  }

@override
  String toString(){
   return 'null (i am a MapListBlackHole)';

  }

@override
get runtimeType=> Null;

}
