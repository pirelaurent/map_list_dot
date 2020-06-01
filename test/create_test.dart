import 'package:json_xpath/src/map_list.dart';

void main (){
  dynamic root = MapList({});
  root.name = "experiment one";
  root.results = [];
  root.results.add({"elapsed time": "15", "temperature":33.1});
  root.results.add({"elapsed time": "30", "temperature":35.0});
  assert(root.results[1].temperature == 35);
}