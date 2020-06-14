import 'package:map_list_dot/map_list_dot_lib.dart';
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
  test('constructor empty ', () {
    dynamic root = MapList();
    assert(root is MapListMap, true);
    assert(root.isEmpty, true);
    root.name = "toto";
    assert(root.name == "toto");
    // add is not a real map syntax but we tolerate this , as long this is a list of key:values
    root.add({"age": 15, "weight": 65});
    assert(root.name == "toto");
  });

  test('constructor empty but List ', () {
    dynamic root = MapList([]);
    assert(root is MapListList, true);
    assert(root.isEmpty, true);
    // add is not a real map syntax but we tolerate this as addAll
    // as long this is a list of key:values
    var x = {"name": "toto", "age": 15, "weight": 65};
    root.add(x);
    //root.add({"name": "toto", "age": 15, "weight": 65});
    assert(root[0].name == "toto");
  });

  test('constructor with json String', () {
    String sJson = r""" {"name": "toto", "age": 15, "weight": 65} """;
    dynamic root = MapList(sJson);
    assert(root is MapListMap, true);
    assert(root.name == "toto");
  });

  test('constructor with a json map made of int ', () {
    dynamic root = MapList({"age": 15, "weight": 65});
    assert(root is MapListMap, true);
    assert(root.age == 15);
  });

  test('constructor with json structured starting as List ', () {
    String sJson =
        r""" [{"name": "toto", "age": 15, "weight": 65},{"name":"zaza", "age" :68}] """;
    var jj = json.decode(sJson);
    dynamic root = MapList(jj);

    assert(root is MapListList, true);
    assert(root[1].name == "zaza");
  });
}
