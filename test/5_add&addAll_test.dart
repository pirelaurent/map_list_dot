import 'package:json_xpath/map_list_lib.dart';
import 'package:test/test.dart';

void main() {
  test('addAll in code', () {
    // caution must be dynamic, var won't work as addAll is not defined in MapList
    dynamic map = MapList({"name": "toto"});
   // print("map.runtimeType ${map.runtimeType}"); // MapListMap
    var map1 = {"A": "aa", "B": "bb"};
    map.addAll(map1);
    assert( map.length == 3);
    assert( map.A == "aa");
    //print('$map after addAll');

    print('-------- list -----------');
    dynamic list = MapList([]);
    //print("list.runtimeType ${list.runtimeType}");// MapListList
    list.add(15);
    list.addAll([1, 2, 3]);
    assert(list.length == 4);
    assert(list[2] == 2);
  });

  test("add raw data int in a List later than root ", () {
    // reset
    dynamic root = MapList();
    root.data = [11,12,13];
    assert(root.data[2]==13);
    print('PLA5: ${root.data} ${root.data.runtimeType}');
    root.data.add(14);
    print('PLA6:root.data ${root.data}');
    assert(root.data[3]==14);

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


  test('addAll in script', () {
    // caution must be dynamic, var won't work as addAll is not defined in MapList
    dynamic map = MapList();
    map.script('name= "toto"');
    map.script('addAll({"A": "aa", "B": "bb"})');
    assert( map.script("length") == 3);
    assert( map.script("A") == "aa");

    /*
     don't work if initialized with data
     type '_InternalLinkedHashMap<String, dynamic>' is not a subtype of type 'Map<String, String>' of 'other'
     */

    map = MapList({"name": "toto"});
    map.script('addAll({"A": "aa", "B": "bb"})');
    assert( map.script("length") == 3);
    assert( map.script("A") == "aa");



    /*
    dynamic list = MapList([]);
    list.add(15);
    list.script('addAll([1, 2, 3])');
    print(list);
    assert(list.script("length") == 4);
    assert(list.script('[2]') == 2);

     */
  });


}
