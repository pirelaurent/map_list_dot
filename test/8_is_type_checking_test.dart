import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  var testFile =
      path.join(Directory.current.path, 'models', 'json', 'super_heroes.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  dynamic root = MapList(jsonString);

  test("check map or list in code ", () {
    //root = MapList({"members": [ { "name": "Bourne", "age": 33 }]});
    assertShow(root is MapList, true);
    assertShow(root is MapListMap, true);
    assert(root.json is Map);
    assertShow(root.members is MapListList, true);
    assertShow(root.members[0] is MapListMap, true);
    assertShow(root.members[0].name is String, true);
    assertShow(root.members[0].age is int, true);
    assertShow(root.members[0].powers is MapListList, true);
    assertShow(root.members[1].powers[1] is String, true);
    assertShow(root.members[1].powers[1], "Damage resistance");
  });

  test("check map or MapListList in interpreter ", () {
    assertShow(root.eval("members") is MapListList, true);
    assertShow(root.eval("members[0]") is MapListMap, true);
    assertShow(root.eval("members[0].name") is String, true);
    assertShow(root.eval("members[0].age") is int, true);
    assertShow(root.eval("members[0].powers") is MapListList, true);
    assertShow(root.eval("members[1].powers[1]") is String, true);
    assertShow(root.eval("members[1].powers[1]"), "Damage resistance");
  });

  test("check coherence of wrapping ", () {
    //root = MapList({"members": [ { "name": "Bourne", "age": 33 }]});

    assert((root is MapListMap) && (root.json is Map));
    assert((root.members is MapListList) && (root.members.json is List));
    assert((root.members[0] is MapListMap) && (root.members[0].json is Map));
    // check using pointers, not copies
    dynamic firstMember = root.members[0];
    assert(firstMember.json == root.eval("members[0]").json);
  });
}
