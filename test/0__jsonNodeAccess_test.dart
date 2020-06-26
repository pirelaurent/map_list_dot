//import 'package:map_lib_dot/src/map_list.dart';
import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

/*

  Generalize assert to show what is the received response against the expected

 */
void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}

/*
 basic tests on get .
 Notice that you can call directly exec
 but it doesn't verify if set or get,it just apply the script

 if logger is in place, this will generate new "Stopped" tests with logs.
 */
void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('starts with a List , then  a List of List , a Map and a String', () {
    var aJson = [
      [1, 2, 3],
      [11, 12],
      {"A": "AA", "B": "BB"},
      "andSoOn"
    ];
/*
  print(jsonNode(aJson, '[0][1]'));
  print(jsonNode(aJson, '[2]["B"]'));
  print(jsonNode(aJson, '[2].length'));
  print(jsonNode(aJson,'[0]'));
  print(jsonNode(aJson,'[2]'));
  print(jsonNode(aJson, '[2].newData'));
  print(jsonNode(aJson, '[0]'));
  */


    assert(jsonNode(aJson, '[0][1]').value == 2);
    assert(jsonNode(aJson, '[2].B').value == "BB");
    assert(jsonNode(aJson, '[2].["B"]').value == "BB");
    // accessing the length of the Lists
    assert(jsonNode(aJson, 'length').value == 4);
    // length of a map
    assert(jsonNode(aJson, '[2].length').value == 2);
    // wrong index with error message
    print(
        '----- this test will generate a warning wrong index 3 and returns null -----');
    assert(jsonNode(aJson, '[0][3]').value == null);
    // wrong index but without error message using nullable
    assert(jsonNode(aJson, '[0][3]?').value == null);
  });

  test('starts with a map, then a List and a Map with a List', () {
    var aJson = <String, dynamic>{
      "lot1": [1, 2, 3],
      "lot2": [11, 12],
      "names": {
        "A": "AA",
        "B": "BB",
        "x": [100, 200, 300, 400]
      },
      "more": "andSoOn"
    };
    assert(jsonNode(aJson, 'lot1[1]').value == 2);
    assert(jsonNode(aJson, 'more').value == "andSoOn");
    assert(jsonNode(aJson, 'lot2[0]').value == 11);
    assert(jsonNode(aJson, 'names.B').value == "BB");
    assert(jsonNode(aJson, 'names["B"]').value == "BB");
    assert(jsonNode(aJson, 'names.x[0]').value == 100);
    // check length
    assert(jsonNode(aJson, 'names.length').value == 3);
    assert(jsonNode(aJson, 'names.x.length').value == 4);
  });

  test(' jsonNode interpreted Empty method ', () {
    var aJson = <String, dynamic>{
      "first": [],
      "second": {},
      "third": [1, 2, 3],
      "fourth": {"A": "AA", "B": "BB"}
    };
    // check root
    assert(jsonNode(aJson, 'isNotEmpty').value == true);
    // check empty list
    assert(jsonNode(aJson, 'first.isEmpty').value == true);
    // check empty map
    assert(jsonNode(aJson, 'second.isEmpty').value == true);
    // check non empty list
    assert(jsonNode(aJson, 'third.isNotEmpty').value == true);
    // check non empty map
    assert(jsonNode(aJson, 'fourth.isNotEmpty').value == true);
  });

  test(' jsonNode last interpreted in a List ', () {
    var aJson = [
      1,
      2,
      [11, 12, 13],
      {"A": "AA", "B": "BB"},
      4
    ];
    assert(jsonNode(aJson, 'last').value == 4);
    assert(jsonNode(aJson, '[2].last').value == 13);
    print('----- these tests will generate 2 warning about "last" usage -----');
    // calling "last" must be on a List. Here is on a int . null returned
    assert(jsonNode(aJson, '[1].last').value == null);
    // same warning on a map
    assert(jsonNode(aJson, '[3].last').value == null);
  });

  test('json with length ', () {
    var aJson = {
      "squad": {
        "members": [1, 2, 3, 4]
      }
    };
    assert(jsonNode(aJson, 'squad.members.length').value == 4);
  });

  test('jsonNode unexisting data : value null but first part ok ', () {
    var aJson = {
      "squad": {
        "members": [1, 2, 3, 4]
      }
    };
    // unknown: result null but leave a chance to create if necessary
    //(map){members: [1, 2...  --- wrongMembers -> (Null) null
    assert((jsonNode(aJson, 'squad.wrongMembers').fromNode is Map));
    assert(jsonNode(aJson, 'squad.wrongMembers').edge == "wrongMembers");
    assert(jsonNode(aJson, 'squad.wrongMembers').value == null);
    // if not possible to progress, jsonNode cuts asap like above
    assert(jsonNode(aJson, 'squad.wrongMembers.length').value == null);
  });

}
