import 'package:map_list_dot/map_list_dot_lib.dart';
import 'package:test/test.dart';

void main() {
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
    root.script('name = [10,11,12,]');
    assert(root.name == null);
  });

  test('applying spurious index on a map  ', () {
    dynamic root = MapList({"name": "zaza", "age": 12});
    //root.name[toto]="riri"; // syntax error
    //root.name[0] = "lulu";  // syntax error
    root.script('name["toto"]="riri"');
    //** name["toto"]="riri": index ["toto"] must be applied to a map. null returned
    // and name uncheanged:
    assert(root.name == "zaza");
    //** name[toto]="riri": index [toto] must be applied to a map. null returned
    root.script('name[toto]="riri"');
    assert(root.name == "zaza");
    // root.name[0] = "lulu"; cannot be done in code
    root.script('name[0]="lulu"');
    //** name[0]="lulu": [0] must be applied to a List. null returned
    assert(root.name == "zaza");

  });

  test('applying spurious index on a map bis ', () {
    dynamic root = MapList({"name": "zaza", "age": 12});
    assert(root.name == "zaza");
    //** [255] = 20: [255] must be applied to a List. null returned
    root.script(" [255] = 20"); //
//** '[255]' = 20: [255] must be applied to a List. null returned
    root.script(" '[255]' = 20");
    root.script('value =666');
    assert(root.script('valeur') == null);
    // same with trying to change a value
    // root.name[0] = "lulu"; cannot be done in code
    assert(root.name == "zaza");
    // now with a MapList
    root = MapList([1, 2, 3, 4]);
    root.script(" [255] = 20");
    //'[255]' = 20: wrong index [255]. null returned
    root.script(" '[255]' = 20");
  });
  test('trapp out of range in script ', () {
    dynamic root = MapList([0, 1, 2, 3, 4]);
    // calling a key on a list
    assert(root.script('price[200]') == null);

    assert(root.script('[2]') == 2);
    assert(root[2] == 2);

    assert(root[200] == null);
    assert(root.script('[200]') == null);

    dynamic book = MapList({
      "name": "test",
      "price": [0, 1, 2, 3, 4]
    });
    assert(book.script('price[200]') == null);
  });
}
