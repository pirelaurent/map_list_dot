import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

///
/// check methods
///   clear
///   isEmpty
///   isNotEmpty
///   remove
void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('tests about containsKey isEmpty, isNotEmpty, clear , remove , last ',
      () {
    dynamic root = MapList('{ "name":"zaza", "age": 7, "scores": [10,20,30]}');
    assert(root.containsKey("age"));
    assert(root.scores.isNotEmpty);
    root.scores.remove(20);
    assert(root.scores[1] == 30);
    // access the end by special name last
    root.scores.last = 100;
    assert(root.scores[1] == 100);
    assert(root.scores.last == 100, '${root.scores.last}');

    // clear data, not holder
    root.scores.clear();
    assert(root.scores.isEmpty);
    assert(root.length == 3);
    root.remove("scores");
    assert(root.length == 2);
    root.clear();
    assert(root.length == 0);
  });

  test(
      'tests interpreter about containsKey isEmpty, isNotEmpty, clear , remove , last ',
      () {
    dynamic root = MapList('{ "name":"zaza", "age": 7, "scores": [10,20,30]}');
    // contains is not available but a get will return null
    assert(root.exec("age") != null);
    assert(root.exec('scores.isNotEmpty'));
    root.exec('scores.remove(20)');
    // verify remove
    assert(root.exec('scores[1]') == 30);
    // verify using last

    assert(root.exec('scores.last') == 30);

    // add at the end by special name last

    root.exec('scores.last = 100');

    assert(root.exec('scores[1]') == 100);
    // clear data, not holder
    root.exec('scores.clear()');
    assert(root.exec('scores.isEmpty'));
    assert(root.exec('length') == 3);
    root.exec('remove("scores")');
    assert(root.exec('length') == 2);
    root.exec('clear()');
    assert(root.exec('length') == 0);
  });

  test('change length of a List ', () {
    dynamic root = MapList({
      "squad": {
        "members": [1, 2, 3, 4]
      }
    });
    assert(root.exec('squad.members.length') == 4);
    root.exec('squad.members.length = 2');
    assert(root.exec('squad.members.length') == 2);
    root.exec('squad.members.length = 10');
    assert(root.exec('squad.members.length') == 10);
    assert(root.exec('squad.members[2]') == null);
  });

  test('test clear on a List ', () {
    dynamic root = MapList({
      "squad": {
        "members": [1, 2, 3, 4]
      }
    });
    assert(root.exec('squad.members.length') == 4);
    root.exec('squad.members.clear()');
    assert(root.exec('squad.members.length') == 0);
    root.exec('squad.members.length = 10');
    assert(root.exec('squad.members.length') == 10);
    assert(root.exec('squad.members[0]') == null);
  });

  test('overlap of .length method and data ', () {
   dynamic store = MapList('{"bikes":[{"name":"Fonlupt", "length":2.1, "color" : "green" }]}');
   assert(store.exec('bikes[0].length') == 3);
   assert(store.exec('bikes[0]["length"]')== 2.1);
   assert(store.bikes[0].length == 3);
   assert (store.bikes[0]["length"] == 2.1);

  });
}
