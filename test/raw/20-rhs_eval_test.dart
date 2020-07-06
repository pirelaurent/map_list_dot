import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });


  test('check rhs evaluation in dart code & contains',()
  {
    dynamic BB = MapListMap();
    BB.categories = {};
    BB.categories.addAll(
        {"contemporary": 0, "popular": 1, "adventurer": 2, "artist": 3});

    BB.addAll({"persons": []});
    BB.persons.add({
      "name": "Polo",
      "firstName": "Marco",
      "categories": [],
      "friends": []
    });
    BB.persons.last.categories.addAll(
        [BB.categories.adventurer, BB.categories.popular]);
    //
    BB.persons.add({
      "name": "Magellan",
      "firstName": "Fernando",
      "categories": [],
      "friends": []
    });
    // set same categories as previous
    BB.persons.last.categories = BB.persons[0].categories;
    /*
    everything works in dart code as rhs is also dart code
  */
    assert(BB.persons.last.categories.contains(BB.categories.adventurer));
  });

  test('check rhs evaluation in interpreter & contains',()
  {
    dynamic BB = MapListMap();
    BB.eval('categories = {}');
    BB.eval('categories.addAll({"contemporary": 0, "popular": 1, "adventurer": 2, "artist": 3})');

    BB.eval('addAll({"persons": []})');
    BB.eval('''persons.add({
      "name": "Polo",
      "firstName": "Marco",
      "categories": [],
      "friends": []
    })''');
     BB.eval('''persons.last.categories.addAll(
        [categories.adventurer, categories.popular]);
        ''');
    //
    print(BB.persons);
    BB.eval('''persons.add({
      "name": "Magellan",
      "firstName": "Fernando",
      "categories": [],
      "friends": []
    })''');
    // set same categories as previous
    print('----------------- 1');
    print( BB.eval('persons[0].categories'));
    print( BB.eval('persons.last.categories'));
    print('--------------------azazaza');
    BB.eval('persons.last.categories = persons[0].categories');
    /*
  everything works in dart code as rhs is also dart code
  */
    print(BB);
    print('--------------------');
    print( BB.eval('persons.last.categories'));

    assert(BB.persons.last.categories.contains(BB.categories.adventurer));
    /*
   Now in interpreter : !
   contains is not defined.
   */

    assert(BB.eval('persons.last.categories.contains(categories.adventurer)') == true);
   assert(BB.eval('persons.last.categories.contains(categories.politician)') ==false);

  });




}