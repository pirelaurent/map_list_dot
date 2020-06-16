import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

void main() {
  //set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  print(
      '------------------  These tests will write trapped errors on stdErr -------------');

  test('wrong json in constructor ', () {
    // dynamic root = MapList({"this": is not a[12] valid entry }); syntax error
    dynamic root = MapList('{"this": is not a[12] valid entry }');
    assert(root == null);
  });

  test('wrong json in assignment  ', () {
    dynamic root = MapList({"name": "zaza"});
    root.name = [
      10,
      11,
      12,
    ];
    root.set('name = [10,11,12,]');
    assert(root.name == null);
  });

  test('applying spurious index on a map  ', () {
    dynamic root = MapList({"name": "zaza", "age": 12});
    //root.name[toto]="riri"; // syntax error
    //root.name[0] = "lulu";  // syntax error
    root.set('name["toto"]="riri"');
    //** name["toto"]="riri": index ["toto"] must be applied to a map. null returned
    // and name uncheanged:
    assert(root.name == "zaza");
    //** name[toto]="riri": index [toto] must be applied to a map. null returned
    root.set('name[toto]="riri"');
    assert(root.name == "zaza");
    // root.name[0] = "lulu"; cannot be done in code
    root.set('name[0]="lulu"');
    //** name[0]="lulu": [0] must be applied to a List. null returned
    assert(root.name == "zaza");

  });

  test('applying spurious index on a map bis ', () {
    dynamic root = MapList({"name": "zaza", "age": 12});
    assert(root.name == "zaza");
    //** [255] = 20: [255] must be applied to a List. null returned
    root.set(" [255] = 20"); //
//** '[255]' = 20: [255] must be applied to a List. null returned
    root.set(" '[255]' = 20");
    root.set('value =666');
    assert(root.get('valeur') == null);
    // same with trying to change a value
    // root.name[0] = "lulu"; cannot be done in code
    assert(root.name == "zaza");
    // now with a MapList
    root = MapList([1, 2, 3, 4]);
    root.set(" [255] = 20");
    //'[255]' = 20: wrong index [255]. null returned
    root.set(" '[255]' = 20");
  });
  test('trapp out of range in exec', () {
    dynamic root = MapList([0, 1, 2, 3, 4]);
    // calling a key on a list
    assert(root.get('price[200]') == null);

    assert(root.get('[2]') == 2);
    assert(root[2] == 2);

    assert(root[200] == null);
    assert(root.get('[200]') == null);

    dynamic book = MapList({
      "name": "test",
      "price": [0, 1, 2, 3, 4]
    });
    assert(book.get('price[200]') == null);
  });

  test(' wrong function calls on clear  ',(){
    dynamic root = MapList([0, 1, 2, 3, 4]);
    root.set('clear()');
    //** warning : clear(). Calling set without = .Be sure it's not a get or an exec .no action done
    root.exec('clearAll()');
    //** unknown function : clearAll() . No action done
    root.exec('clear');
    //**  cannot search a key (clear) in a List<dynamic>
    root.exec('clear()'); // ok
    assert(root.length == 0);
  });


  test(' wrong function calls with last  ',(){
    dynamic root = MapList([0, 1, 2, 3, 4]);
    root.get('root.last');
    // **  cannot search a key (root.last) in a List<dynamic>
    root.get('last'); //ok
    root.get('[last]');
    //** warning : [11,12,13]. Calling set without = .Be sure it's not a get or an exec .no action done
    root.set('[11,12,13]');
   //** warning : [11,12,13]. Calling set without = .Be sure it's not a get or an exec .no action done
    root.set('= [11,12,13]');//
    root.exec('add({"name":"polo", "age":33})');
    dynamic x = root.get('last');
    assert(x.age == 33);
    assert(root.get('last').age  == 33);
    assert(root.get('last.age')  == 33);
  });
}
