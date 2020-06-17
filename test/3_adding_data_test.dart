import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

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


  dynamic root;

  test("add raw data int in a List", () {
    // reset

    dynamic root = MapList();
    var hash1 = root.json.hashCode;
    root.data = [11, 12, 13];
    assert(root.data[2] == 13);
    // internal control of pointers : root stays the same once data added
    var hash2 = root.json.hashCode;
    assert(hash1 == hash2, ' bad mutation on root.json');
    // check different access points on the same data
    var hash3 = root.data.json.hashCode;
    var hash33 = root.json["data"].hashCode;
    assert(hash3 == hash33, '$hash3 $hash33');
    // check that an add don't change the pointers
    root.data.add(14);
    assert(root.data[3] == 14);
    var hash333 = root.data.json.hashCode;
    assert(hash3 == hash333, '$hash3 $hash333');
  });

  test("add a List to a List", () {
    // reset
    root = MapList();
    root.data = [11, 12, 13];
    assert(root.data[2] == 13);
    // cannot write like this :
    root.exec('data.add(31)');
    assert(root.data[3] == 31);
  });

  test("add raw heterogeneous data in a List", () {
    // reset
    root = MapList();
    root.data = [11, 12, 13];
    assert(root.data[2] == 13);
    /* by default a [11,12,13] is a List<int> can't add a string
    root.data.add("hello");
    type 'String' is not a subtype of type 'int' of 'value'
    */
    // so better to do like following :
    root.data = []; // will create a List<dynamic>
    root.data.addAll([11, 12, 13]); // addAll for initialising with <int>
    assert(root.data[2] == 13);
    root.data.add("hello");
    assert(root.data[3] == "hello");
    root.exec('data.add(15.5)');
    assert(root.data[4] == 15.5);
    // now add a map
    root.data.add({"name": "polo", "age":27});
    assert(root.data[5] is MapListMap);
    // interpreter
    root.exec('data.add({"name": "pili", "age":20})');
    assert(root.data[6] is MapListMap);
    assert(root.data[5].name == "polo" );

  });

  test(" add json to a List , direct and interpreted  ", () {
    root = MapList();
    root.results = [];
    // code : the map in Map <String, int> we can add other same couples
    root.results.add({"elapsed_time": 30, "temperature": 18});
    root.results.add({"elapsed_time": 60, "temperature": 40});
    assert(root.results[1].temperature == 40);
    // script
    root.exec('results.add({"elapsed_time": 120, "temperature": 58  })');
    assert(root.results[2].temperature == 58);
  });



  test("Adding new entries on an existing map ", () {
    // code
    root = MapList();
    root.results = [];
    // doing the following results[0] is a Map<String,int>
    root.results.add({"elapsed_time": 30, "temperature": 18});
    // as we plan to add a <String,String> in this results[1] : we cast
    root.results.add( <String,dynamic>{"elapsed_time": 60, "temperature": 40});
    root.results[1].time = "12:58:00";
    assert(root.results[1].time is String, '${root.results[1].time}');
    // script
    root.set('results[1].duration = "01:00:00"');
    assert(root.results[1].duration is String, '${root.results[1].duration}');

  });

  // seems that add and addAll are the same
  test("extends a map to a map in code  with add", () {
    // reset
    dynamic car = MapList();
    car.name = "Ford";
    car.color = "blue";
    assert(car.color == "blue");
    // be sure to use addAll, not add on a map
    //** Symbol("add") {price: 5000, fuel: diesel, hybrid: false} is invalid. No action done
    car.addAll(<String,dynamic>{"price": 5001, "fuel": "diesel", "hybrid": false});
    //assert(car.length == 5);
  });


}
