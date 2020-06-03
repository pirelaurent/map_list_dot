import 'package:json_xpath/src/map_list.dart';
import 'package:test/test.dart';

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected,
      "expected: $expected  ${expected.runtimeType} got: $what ${what.runtimeType}");
}

void main() {
  dynamic root = MapList();
  // ad a name to the map and a list of results
  root.name = "experiment one";
  root.results = [];

  test("test add json to a doted List , direct and interpreted  ", () {
    root.results.add({"elapsed time": 15, "temperature": 33.1});
    root.results.add({"elapsed time": 30, "temperature": 35.0});
    assertShow(root.results[1].temperature, 35);
    // now add another entry (a map) to the root by interpreter
    root.path('conditions = {"meteo":37, "wind":53 } ');
    assertShow(root.conditions.wind, 53);
  });

  test("test add wrong json to a doted List , direct and interpreted  ", () {
    root.results.add({"elapsed time": 60, "temperature": 40  , });
 print(root);
    assertShow(root.results[2].temperature, 40);
    // now add another entry (a map) to the root by interpreter
    root.path('conditions = {"meteo":37, "wind":53 , } ');
    print(root);
    
    assertShow(root.conditions.isEmpty, true);
  });



  test("dynamic creation of data with & without assignment", () {
    // new entries create empty map to allow continuation
    assertShow((root.conditions.sunrise is Map), true);
    assertShow((root.conditions.sunrise.length), 0);
    // new entries with assignement create an end leaf key-value
    assertShow((root.conditions.sunrise = null), null);
    // reuse can remplace current by another value in interpreter
    root.path('conditions.sunrise = 17:30');
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
    assertShow(root.path("map1.leaf2[1]"), "e");
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
}
