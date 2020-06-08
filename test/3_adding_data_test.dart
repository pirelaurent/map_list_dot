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
  dynamic root;


  test("add raw data int in a List", () {
    // reset
    dynamic root = MapList();
    root.data = [11,12,13];
    assert(root.data[2]==13);
    root.data.add(14);
    assert(root.data[3]==14);
    // now in script
    root.script('data.add(15)');
    assert(root.data[4]==15);
  });


  test("add a map in a List of int ", () {
    // reset
    root = MapList();
    root.data = [11,12,13];
    assert(root.data[2]==13);
    //print('${root.data.runtimeType}');//MapListList
    root.data.add({"name":10});
    assert(root.data[3] is Map);
    root.script('data.add({"name":20})');
    assert(root.data[4] is Map);

    // can do that in code
    Map m1 = {"pouet":10};
    root.data.add(m1);
    assert(root.data[5].pouet == 10);
    // of course cannot do that in script as m1 is unknown
    root.script('data.add(m1)');
  });





  test("add raw heterogeneous data in a List", () {
    // reset
    root = MapList();
    root.data = [11,12,13];
    assert(root.data[2]==13);
    // by default a [11,12,13] is a List<int> can't add a string
    root.data.add("hello");
    assert(root.data[3]=="hello");
    root.script('data.add(15.5)');
    assert(root.data[4]==15.5);
    //-------------assert(root.data[3]==14);
  });



  /*
   sharing root between test to share data needs to run all tests,
   not one per one
   */

    test(" add json to a doted List , direct and interpreted  ", () {

      root.results = [];
    // code
      root.results.add({"elapsed_time": 30, "temperature": 18   });
      root.results.add({"elapsed_time": 60, "temperature": 40 });
      assert(root.results[1].temperature ==  40);
    // script
      root.script('results.add({"elapsed_time": 120, "temperature": 58  })');
      assert(root.results[2].temperature ==  58);

  });

    test("Adding new entries on an existing map ", () {
      // code
      root.results[1].time = "12:58:00";
      // script
      root.script('results[1].duration = "01:00:00"');
      assert(root.results[1].duration is String, true);

    });


  test("creation of data at very beginning", () {
    root = MapList();
    root.results = [];
    root.results.add({"elapsed_time": 30, "temperature": 18   });
    root.elapsed_time_total = 33;
     assert(root.elapsed_time_total == 33);
     assert(root.length ==2);
     root.script('elapsed_time_total = null');
    assert(root.elapsed_time_total == null);
  });




  test("add a List to a List", () {
    // reset
    root = MapList();
    root.data = [11,12,13];
    assert(root.data[2]==13);
  // cannot write like this :
    root.script('data.add(31)');
    assert(root.data[3]==31);
    print( '*** something todo on List on list data.add([another list])');
  });

  // seems that add and addAll are the same
  test("extends a map to a map in code  with add", () {
    // reset
    dynamic car = MapList();
    car.name = "Ford";
    car.color = "blue";
    assert(car.color =="blue");
    car.add({ "price": 5000, "fuel":"diesel","hybrid":false});
    assert(car.length ==5);
  });

  // seems that add and addAll are the same
  test("extends a map to a map in code with addALl  ", () {
    // reset
    dynamic car = MapList();
    car.name = "Ford";
    car.color = "blue";
    assert(car.color =="blue");
    car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false});
    assert(car.length ==5);
  });

  test("extends a map to a map in script  ", () {
    // reset
    dynamic car = MapList();
    car.name = "Ford";
    car.color = "blue";
    assert(car.color =="blue");
    car.script('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})');
    assert(car.length ==5);

  });


  test("extends a map to a map in script with add ", () {
    // reset
    dynamic car = MapList();
    car.name = "Ford";
    car.color = "blue";
    assert(car.color =="blue");
    car.script('add({ "price": 5000, "fuel":"diesel","hybrid":false})');
    assert(car.length ==5);

  });




/*
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
