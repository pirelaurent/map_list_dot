import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('addAll in code', () {
    // caution must be dynamic, var won't work as addAll is not defined in MapList
    dynamic map = MapList({"name": "toto"});

    var map1 = {"A": "aa", "B": "bb"};
    map.addAll(map1);
    assert(map.length == 3);
    assert(map.A == "aa");

    dynamic list = MapList([]);

    list.add(15);
    list.addAll([1, 2, 3]);
    assert(list.length == 4);
    assert(list[2] == 2);
    list.add(16);
    assert(list.length == 5);
  });

  test("add raw data int in a List later than root ", () {
    // reset
    dynamic root = MapList();
    root.data = [11, 12, 13];
    assert(root.data[2] == 13);
    root.data.add(14);
    assert(root.data[3] == 14);
  });

  test("extends a map to a map by addAll in exec ", () {
    // reset
    dynamic car = MapList();
    car.name = "Ford";
    car.color = "blue";
    assert(car.color == "blue");
    car.exec('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})');
    assert(car.length == 5);
  });

  test("extends a map to a map by addAll   ", () {
    // reset
    dynamic car = MapList();
    car.name = "Ford";
    car.color = "blue";
    assert(car.color == "blue");
    car.addAll({"price": 5000, "fuel": "diesel", "hybrid": false});
    assert(car.length == 5);
  });

  test('addAll in script', () {

    dynamic map = MapList();
    /*
     in interpreter, every json string is converted to dynamic
     internal map addAll check compatibility
     */
    map = MapList({"name": "toto"});
    map.exec('addAll({"A": "aa", "B": "bb"})');
    assert(map.get("length") == 3);
    assert(map.get("A") == "aa");

    // caution must be dynamic, var won't work as addAll is not defined in MapList

    map.set('name = "toto"');
    print(map);
    map.exec('addAll({"A": "aa", "B": "bb"})');
    print(map);
    assert(map.get("length") == 3);
    assert(map.get("A") == "aa");


  });

  test('add a MapList to a MapList ', () {
    dynamic map = MapList({"friends": []});
    // add a standard maps & list
    dynamic aGuy = {"name": "polo", "age": 33};
    // print(aGuy.name); will not work as it is not a MapList
    map.friends.add(aGuy);
    aGuy = MapList({"name": "zaza", "age": 44});
    print(aGuy.name); // will return zaza as it is a MapList
    map.friends.add(aGuy);
    aGuy = MapList({"name": "lulu", "age": 66});
    map.friends.add(aGuy);
    print(map);
    assert(map.friends.length == 3);
    assert(map.friends[1].age == 44);
    // remember pointer aGuy is still linked to the internal json
    aGuy.clear();
    assert(map.friends.last.length == 0);
    aGuy.addAll({"name" : "lulu", "age":77, "color":"blue"});
    assert(map.friends[2].age == 77);

    aGuy == null;
    assert(map.friends[2].age == 77);
  });
}
