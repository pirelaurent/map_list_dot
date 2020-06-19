import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

void main() {
  //set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  print(
      '------------------  These tests will log  trapped errors with logging  -------------');

  test('wrong json in constructor ', () {
    // dynamic root = MapList({"this": is not a[12] valid entry }); syntax error
    dynamic root = MapList('{"this": is not a[12] valid entry }');
    assert(root == null);
  });

  test('wrong json in assignment  ', () {
    // to try to add a List in a Map of <String, String> we cast
    dynamic root = MapList(<String, dynamic>{"name": "zaza"});
    // what is allowed in dart is not allowed in json
    root.name = [
      10,
      11,
      12,
    ];
    print (root);
    root.exec('name = [10,11,12,13,]');
    assert(root.name == null, '$root');
  });

  test('applying spurious index on a map  ', () {
    dynamic root = MapList({"name": "zaza", "age": 12});
    //root.name[toto]="riri"; // syntax error
    //root.name[0] = "lulu";  // syntax error
    root.exec('name["toto"]="riri"');
    //** name["toto"]="riri": index ["toto"] must be applied to a map. null returned
    // and name uncheanged:
    assert(root.name == "zaza");
    //** name[toto]="riri": index [toto] must be applied to a map. null returned
    root.exec('name[toto]="riri"');
    assert(root.name == "zaza");
    // root.name[0] = "lulu"; cannot be done in code
    root.exec('name[0]="lulu"');
    //** name[0]="lulu": [0] must be applied to a List. null returned
    assert(root.name == "zaza");
  });

  test('applying spurious index on a map bis ', () {
    dynamic root = MapList({"name": "zaza", "age": 12});
    assert(root.name == "zaza");
    //** [255] = 20: [255] must be applied to a List. null returned
    root.exec(" [255] = 20"); //
//** '[255]' = 20: [255] must be applied to a List. null returned
    root.exec(" '[255]' = 20");
    root.exec('value =666');
    assert(root.exec('valeur') == null);
    // same with trying to change a value
    // root.name[0] = "lulu"; cannot be done in code
    assert(root.name == "zaza");
    // now with a MapList
    root = MapList([1, 2, 3, 4]);
    root.exec(" [255] = 20");
    //'[255]' = 20: wrong index [255]. null returned
    root.exec(" '[255]' = 20");
  });

  test('trapp out of range in exec', () {
    dynamic root = MapList([0, 1, 2, 3, 4]);
    // calling a key on a list
    //print(root.price);  ** Naming error: trying to get a key "price" in a List. Null returned
    assert(root.exec('price[200]') == null);

    assert(root.exec('[2]') == 2);
    assert(root[2] == 2);

    assert(root[200] == null);
    assert(root.exec('[200]') == null);

    dynamic book = MapList({
      "name": "test",
      "price": [0, 1, 2, 3, 4]
    });
    assert(book.exec('price[200]') == null);
  });

  test(' wrong function calls on clear  ', () {
    dynamic root = MapList([0, 1, 2, 3, 4]);
    root.exec('clear()');
    //** warning : clear(). Calling set without = .Be sure it's not a get or an exec .no action done
    root.exec('clearAll()');
    //** unknown function : clearAll() . No action done
    root.exec('clear');
    //**  cannot search a key (clear) in a List<dynamic>
    root.exec('clear()'); // ok
    assert(root.length == 0);
  });

  test(' wrong function calls with last  ', () {
    /* as we plan to add a map to a list<int> we cast it <dynamic>
     the other way could have been :
     1st create an instance of an empty List :root = MapList([]);
     then addAll the data : root.addAll([0, 1, 2, 3, 4])
   */
    dynamic root = MapList(<dynamic>[0, 1, 2, 3, 4]);
    root.exec('root.video.name = "Max"');
    root.exec('root.last');
    // **  cannot search a key (root.last) in a List<dynamic>
    root.exec('last'); //ok
    root.exec('[last]');
    //** warning : [11,12,13]. Calling set without = .Be sure it's not a get or an exec .no action done
    root.exec('[11,12,13]');
    //** warning : [11,12,13]. Calling set without = .Be sure it's not a get or an exec .no action done
    root.exec('= [11,12,13]'); //
    root.exec('add({"name":"polo", "age":33})');
    dynamic x = root.exec('last');
    assert(x.age == 33);
    assert(root.exec('last').age == 33);
    assert(root.exec('last.age') == 33);
  });

  test('more trapped bad assignments ', () {
    dynamic root = MapList();
    root.exec(
        'car = {"name":"Ford", "color":"white"}'); // create and set with json-like string.
    root.exec(
        'car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false})'); //add or merge with function addAll
    root.exec('squad.members = [1,2,3,4]');
    root.exec('squad.members.length = 2');
    root.exec(
        'squad.length = 2'); //** trying to set length on a squad.length. which is not a List no action done.
    root.exec(
        'squad."name" = "Super hero squad"'); // cannot access a String with a key like
  });
}
