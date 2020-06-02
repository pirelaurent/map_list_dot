import 'package:json_xpath/src/map_list.dart';

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}


void main (){
  // make a root as an empty map
  dynamic root = MapList({});
  // ad a name to the map and a list of results
  root.name = "experiment one";
  root.results = [];
  // add some results to the list
  root.results.add({"elapsed time": 15, "temperature":33.1});
  root.results.add({"elapsed time": 30, "temperature":35.0});
  assertShow(root.results[1].temperature,35);
  // wrong indice
  var x =root.results[11].temperature;
  print(x.runtimeType);
  print(x is Null);

  assertShow(root.results[11].temperature,35);

  // now add another map to the root by interpreter
  root.interpret('conditions = {"méteo":37, "wind":53 } ');
  assertShow(root.conditions.wind, 53);
  // ad a wrong json . will be empty {}
  root.interpret('conditionsBis = {"méteo":37, "wind":53 ,  } ');
  assertShow(root.conditionsBis.wind, null);
  // add a


}