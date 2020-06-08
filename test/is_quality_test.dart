
import 'package:json_xpath/map_list_lib.dart';
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
  var testFile = path.join(Directory.current.path, 'test', 'models','json', 'super_heroes.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  dynamic root = MapList(jsonString);

  test("check map or list in code ",()
  {
    assertShow(root is MapListMap, true);
    assertShow(root.members is MapListList, true);
    assertShow(root.members[0] is MapListMap, true);
    assertShow(root.members[0].name is String, true);
    assertShow(root.members[0].age is int, true);
    assertShow(root.members[0].powers is MapListList, true);
    assertShow(root.members[1].powers[1] is String, true);
    assertShow(root.members[1].powers[1], "Damage resistance");
  });

  test("check map or MapListList in interpreter ",()
  {
    assertShow(root.script("members") is MapListList, true);
    assertShow(root.script("members[0]") is MapListMap, true);
    assertShow(root.script("members[0].name") is String, true);
    assertShow(root.script("members[0].age") is int, true);
    assertShow(root.script("members[0].powers") is MapListList, true);
    assertShow(root.script("members[1].powers[1]") is String, true);
    assertShow(root.script("members[1].powers[1]"), "Damage resistance");
  });

}