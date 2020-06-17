import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:convert';

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected,
      "\nexpected: $expected  ${expected.runtimeType} got: $what ${what.runtimeType}");
}

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });



  test('constructor empty ', () {
    dynamic root = MapList();
    assert(root is MapListMap, true);
    assert(root.isEmpty, true);
    root.name = "toto";
    assert(root.name == "toto");
    // add is not a real map syntax but we tolerate this , as long this is a list of key:values
    root.addAll({"age": 15, "weight": 65});
    assert(root.name == "toto");
  });

  test('constructor empty but List ', () {
    dynamic rootList = MapList([]);
    assert(rootList is MapListList, true);
    assert(rootList.isEmpty, true);
    var x = {"name": "toto", "age": 15, "weight": 65};
    rootList.add(x);
    assert(rootList[0].name == "toto");
  });

  test('constructor with json String (not compiled) ', () {
    String sJsonString = r""" {"name": "toto", "age": 15, "weight": 65} """;
    dynamic rootMap = MapList(sJsonString);

    assert(rootMap is MapListMap, true);
    assert(rootMap.name == "toto");
    assert(rootMap.age == 15);
  });


  test('constructor with an already established json ', () {
    String sJson =
        r""" [{"name": "toto", "age": 15, "weight": 65},{"name":"zaza", "age" :68}] """;
    var jj = json.decode(sJson);
    // now give the result to constructor
    dynamic root = MapList(jj);
    assert(root is MapListList, true);
    assert(root[1].name == "zaza");
  });
}
