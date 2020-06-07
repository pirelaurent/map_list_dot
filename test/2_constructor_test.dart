import 'package:json_xpath/src/map_list.dart';
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
    assert(root is Map, true);
    assert(root.isEmpty, true);
    root.name = "toto";
    assert(root.name == "toto");
    // add is not a real map syntax but we tolerate this , as long this is a list of key:values
    root.add({"age": 15, "weight": 65});
    assert(root.name == "toto");
  }
  );


  test('constructor empty but List ', () {
    dynamic root = MapList([]);
    assert(root is List, true);
    assert(root.isEmpty, true);
    // add is not a real map syntax but we tolerate this , as long this is a list of key:values
    var x = {"name": "toto", "age": 15, "weight": 65};
    root.add({"name": "toto", "age": 15, "weight": 65});
    assert(root[0].name == "toto");
  }
  );



  test('constructor with json String', () {
   String sJson= r""" {"name": "toto", "age": 15, "weight": 65} """;
   dynamic root = MapList(sJson);
   assert(root is Map, true);
   assert(root.name == "toto");
  }
  );

  test('constructor with a json map made of int ', () {

    dynamic root = MapList({"age": 15, "weight": 65});
    assert(root is Map, true);
    assert(root.age == 15);
  }
  );



  test('constructor with json structured starting as List ', () {
    String sJson= r""" [{"name": "toto", "age": 15, "weight": 65},{"name":"zaza", "age" :68}] """;
    var jj = json.decode(sJson);
    dynamic root = MapList(jj);

    assert(root is List, true);
    assert(root[1].name == "zaza");
  }
  );

  /*
  test("constructor add wrong json to a doted List , direct and interpreted  ", () {
    root.results.add({"elapsed time": 60, "temperature": 40  , });
 print(root);
    assertShow(root.results[2].temperature, 40);
    // now add another entry (a map) to the root by interpreter
    root.script('conditions = {"meteo":37, "wind":53 , } ');
    print(root);
    
    assertShow(root.conditions.isEmpty, true);
  });
*/

/*
  test("dynamic creation of data with & without assignment", () {
    // new entries create empty map to allow continuation
    assertShow((root.conditions.sunrise is Map), true);
    assertShow((root.conditions.sunrise.length), 0);
    // new entries with assignement create an end leaf key-value
    assertShow((root.conditions.sunrise = null), null);
    // reuse can remplace current by another value in interpreter
    root.script('conditions.sunrise = 17:30');
    assertShow(root.conditions.sunrise, "17:30");
    // add multilevel at once
    root.nawak.moredumb.color = "blue";
    assertShow(root.nawak.moredumb.color, "blue");
  });

  test(" exceptions not trapped on list index ", () {
    // wrong index but tested before
    if (root.results[11] != null)
      assertShow(root.results[11].temperature, null);
    // not tested, must do a try catch and test error
    Error expectedError;
    try {
      assertShow((root.results[11].temperature > 20), true);
    } catch (e) {
      expectedError = e;
      /*
      print("trapped exception by test code : $e");

      trapped exception by test code : NoSuchMethodError: The getter 'temperature' was called on null.
      Receiver: null
      Tried calling: temperature

       */
    }
    assertShow(expectedError.runtimeType, NoSuchMethodError);
  });

  test("use index on a non list entry ", () {
    root.map1.leaf2 = "hello";
    // range on a map return null
    assertShow(root.map1[0], null);
    // can use index on  string :e :second letter of hello
    assertShow(root.script("map1.leaf2[1]"), "e");
    assertShow(root.map1.leaf2[1], "e");

    /*
     but cannot be tested in direct  : as map2 is a String
     it's too late to catch the [] error on a String
     */
    try {
      var result = root.map1.leaf2[1].value;
      assertShow(result == null, true);
    } catch (e) {
      assertShow(e.runtimeType, NoSuchMethodError);
    }
  });
  */

}
