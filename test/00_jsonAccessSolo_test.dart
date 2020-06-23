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
 */
void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('classical query starting by a List', () {
    var aJson = [
      [1, 2, 3],
      [11, 12],
      {"A": "AA", "B": "BB"},
      "andSoOn"
    ];

    assert(jsonNode(aJson, '[0][1]').value == 2);
    assert(jsonNode(aJson, '[2]["B"]').value == "BB");
    // wrong index with error message
    print('this test will generate a warning and returns null');
    assert(jsonNode(aJson, '[0][3]').value == null);
    // wrong index without error message with nullable
    assert(jsonNode(aJson, '[0][3]?').value == null);
    // accessing the length of the Lists
    assert(jsonNode(aJson, 'length').value == 4);
    // length of a map
    assert(jsonNode(aJson, '[2].length').value == 2);
  });

  test('classical query starting by a Map ', () {
    var aJson = <String, dynamic>{
      "lot1": [1, 2, 3],
      "lot2": [11, 12],
      "names": {
        "A": "AA",
        "B": "BB",
        "x": [100, 200, 300, 400]
      }
    };
    assert(jsonNode(aJson, 'lot1[1]').value == 2);
    assert(jsonNode(aJson, 'lot2[0]').value == 11);
    assert(jsonNode(aJson, 'names.B').value == "BB");
    assert(jsonNode(aJson, 'names["B"]').value == "BB");
    assert(jsonNode(aJson, 'names.x[0]').value == 100);
    // check length
    assert(jsonNode(aJson, 'names.length').value == 3);
    assert(jsonNode(aJson, 'names.x.length').value == 4);
  });

  test(' json interpreted Empty method ', () {
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

  test(' json interpreted last in a List ', () {
    var aJson =[1,2,[11,12,13],4];
    assert(jsonNode(aJson, 'last').value == 4);
    assert(jsonNode(aJson, '[2].last').value == 13);
    // some errors
    assert(jsonNode(aJson, '[1].last').value == null);
    var aJsonBis = {"A": "AA", "B": "BB"};
    assert(jsonNode(aJsonBis, 'last').value == null);
  });

 test('json with length ',(){
   var aJson = {"squad": {"members":  [1,2,3,4]}};
   assert(jsonNode(aJson, 'squad.members.length').value == 4);
 });


}
