//import 'package:map_lib_dot/src/map_list.dart';
import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

/*

  Generalize assert to show what is the received response against the expected if wrong

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
  print(JsonNode(aJson, '[0][1]'));
  print(JsonNode(aJson, '[2]["B"]'));
  print(JsonNode(aJson, '[2].length'));
  print(JsonNode(aJson,'[0]'));
  print(JsonNode(aJson,'[2]'));
  print(JsonNode(aJson, '[2].newData'));
  print(JsonNode(aJson, '[0]'));
  */

    assert(JsonNode(aJson, '[0][1]').value == 2);
    assert(JsonNode(aJson, '[2].B').value == "BB");
    assert(JsonNode(aJson, '[2].["B"]').value == "BB");
    // accessing the length of the Lists
    assert(JsonNode(aJson, 'length').value == 4);
    // length of a map
    assert(JsonNode(aJson, '[2].length').value == 2);
    // wrong index with error message
    print(
        '----- this test will generate a warning "wrong index 3" and returns null -----');
    assertShow(JsonNode(aJson, '[0][3]').value, null);
    // wrong index but without error message using nullable
    assert(JsonNode(aJson, '[0][3]?').value == null);
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
    assert(JsonNode(aJson, 'lot1[1]').value == 2);
    assert(JsonNode(aJson, 'more').value == "andSoOn");
    assert(JsonNode(aJson, 'lot2[0]').value == 11);
    assert(JsonNode(aJson, 'names.B').value == "BB");
    assert(JsonNode(aJson, 'names["B"]').value == "BB");
    assert(JsonNode(aJson, 'names.x[0]').value == 100);
    // check length
    assert(JsonNode(aJson, 'names.length').value == 3);
    assert(JsonNode(aJson, 'names.x.length').value == 4);
  });

  test(' JsonNode interpreted Empty method ', () {
    var aJson = <String, dynamic>{
      "first": [],
      "second": {},
      "third": [1, 2, 3],
      "fourth": {"A": "AA", "B": "BB"}
    };
    // check root
    assert(JsonNode(aJson, 'isNotEmpty').value == true);
    // check empty list
    assert(JsonNode(aJson, 'first.isEmpty').value == true);
    // check empty map
    assert(JsonNode(aJson, 'second.isEmpty').value == true);
    // check non empty list
    assert(JsonNode(aJson, 'third.isNotEmpty').value == true);
    // check non empty map
    assert(JsonNode(aJson, 'fourth.isNotEmpty').value == true);
  });

  test(' JsonNode last interpreted in a List ', () {
    var aJson = [
      1,
      2,
      [11, 12, 13],
      {"A": "AA", "B": "BB"},
      4
    ];
    assert(JsonNode(aJson, 'last').value == 4);
    assert(JsonNode(aJson, '[2].last').value == 13);
    print('----- these tests will generate 2 warning about "last" usage -----');
    // calling "last" must be on a List. Here is on a int . null returned
    assertShow(JsonNode(aJson, '[1].last').value, null);
    // same warning on a map
    assertShow(JsonNode(aJson, '[3].last').value, null);
  });

  test('json with length ', () {
    var aJson = {
      "squad": {
        "members": [1, 2, 3, 4]
      }
    };
    assert(JsonNode(aJson, 'squad.members.length').value == 4);
  });

  test('JsonNode unexisting data : further value null but first part accepted ',
      () {
    var aJson = {
      "squad": {
        "members": [1, 2, 3, 4]
      }
    };
    // unknown: return null , not error : leave a chance to create if necessary
    //(map){members: [1, 2...  --- wrongMembers -> (Null) null
    assert((JsonNode(aJson, 'squad.wrongMembers').fromNode is Map));
    assert(JsonNode(aJson, 'squad.wrongMembers').edge == "wrongMembers");
    assert(JsonNode(aJson, 'squad.wrongMembers').value == null);
    // if not possible to progress, JsonNode cuts asap like above
    assert(JsonNode(aJson, 'squad.wrongMembers.length').value == null);
    assert(JsonNode(aJson, 'squad.wrongMembers[0]').value == null);
  });
}//main
