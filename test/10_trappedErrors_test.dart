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

  test('trap out of range in exec', () {
    dynamic root = MapList([0, 1, 2, 3, 4]);
    // calling a key on a list
    //print(root.price);  ** Naming error: trying to get a key "price" in a List. Null returned
    assert(root.exec('price[200]') == null);

    assert(root.exec('[2]') == 2);
    assert(root[2] == 2);

    assert(root[200] == null);
    assert(root.exec('[200]') == null);
   // wrong index 200 on the List<int> [0, 1, 2, 3, 4]
    dynamic book = MapList({
      "name": "test",
      "price": [0, 1, 2, 3, 4]
    });
    assert(book.exec('price[200]') == null);
    // wrong index 200 on the List<int> [0, 1, 2, 3, 4]
  });

  test(' wrong function calls on clear  ', () {
    dynamic root = MapList([0, 1, 2, 3, 4]);
    root.exec('clearAll()');
    //** unknown function : clearAll() . No action done
    root.exec('clear');
    //try to access [] as a Map with key clear. null returned
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
    root.exec('[11,12,13]');
    print(root);


    root.exec('video.name = "Max"');
    //try to access [0, 1, 2, 3, 4] as a Map with key video. null returned
    //try to apply [video.name = "Max"] on a: Null node. No action done
    root.exec('root.last');
    // try to access [0, 1, 2, 3, 4] as a Map with key root. null returned
    root.exec('last'); //ok
    root.exec('[last]'); // allowed

    // ** warning : [11,12,13]. Calling set without = .Be sure it's not a get or an exec .no action done

    root.exec('= [11,12,13]');
    //try to apply [= [11,12,13]] on a: Null node. No action done

    root.exec('add({"name":"polo", "age":33})');
    dynamic x = root.exec('last');
    assert(x.age == 33);
    assert(root.exec('last').age == 33);
    assert(root.exec('last.age') == 33);

  });

  test('more trapped bad assignments ', () {
    dynamic root = MapList({
      "squad": {
        "members": [1, 2, 3, 4]
      }
    });

    root.exec('squad.length = 2');
    //unable to change length on a Map squad.length = 2 . no action done
    //as map is not <String, dynamic> in original set up, this will fail:
    root.exec('car = 22');
    /*
    unable to assign car = 22. Think about <String,dynamic> Maps and <dynamic> Lists. No action done.
    type 'int' is not a subtype of type 'Map<String, List<int>>' of 'value'
    */

    // now recreate same with an interpreted String : will create a correct json
    root = MapList('{"squad": {"members": [1, 2, 3, 4]}}');
    root.exec('car = 22');
    // now change the type of content
    root.exec('car = {"name":"Ford", "color":"white"}');
    // and extends
    root.exec(
        'car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false})'); //add or merge with function addAll

    root.exec('squad."name" = "Super hero squad"');
    // Avoid to use quotes around notation : "name" in squad."name" = "Super hero squad"
    assert(root.squad.name == "Super hero squad");
  });

  test('very basic creation of data in an existing well typed ', () {
    dynamic root = MapList(<String, dynamic>{
      "squad": {
        "members": [1, 2, 3, 4]
      }
    });
    root.exec('car = 12');
    assert(root.car == 12);
    assert(root.exec('car') == 12);
  });
}
