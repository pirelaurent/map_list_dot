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
    assert(root.eval("age") != null);
    assert(root.eval('scores.isNotEmpty'));
    root.eval('scores.remove(20)');
    // verify remove
    assert(root.eval('scores[1]') == 30);
    // verify using last

    assert(root.eval('scores.last') == 30);

    // add at the end by special name last

    root.eval('scores.last = 100');

    assert(root.eval('scores[1]') == 100);
    // clear data, not holder
    root.eval('scores.clear()');
    assert(root.eval('scores.isEmpty'));
    assert(root.eval('length') == 3);
    root.eval('remove("scores")');
    assert(root.eval('length') == 2);
    root.eval('clear()');
    assert(root.eval('length') == 0);
  });

  test('change length of a List ', () {
    dynamic root = MapList({
      "squad": {
        "members": [1, 2, 3, 4]
      }
    });
    assert(root.eval('squad.members.length') == 4);
    root.eval('squad.members.length = 2');
    assert(root.eval('squad.members.length') == 2);
    root.eval('squad.members.length = 10');
    assert(root.eval('squad.members.length') == 10);
    assert(root.eval('squad.members[2]') == null);
  });

  test('test clear on a List ', () {
    dynamic root = MapList({
      "squad": {
        "members": [1, 2, 3, 4]
      }
    });
    assert(root.eval('squad.members.length') == 4);
    root.eval('squad.members.clear()');
    assert(root.eval('squad.members.length') == 0);
    root.eval('squad.members.length = 10');
    assert(root.eval('squad.members.length') == 10);
    assert(root.eval('squad.members[0]') == null);
  });

  test('overlap of .length method and data ', () {
    dynamic store = MapList(
        '{"bikes":[{"name":"Fonlupt", "length":2.1, "color" : "green" }]}');
    assert(store.eval('bikes[0].length') == 3);
    assert(store.eval('bikes[0]["length"]') == 2.1);
    assert(store.bikes[0].length == 3);
    assert(store.bikes[0]["length"] == 2.1);
  });
}
