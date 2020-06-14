import 'package:map_list_dot/map_list_dot_lib.dart';
import 'package:test/test.dart';

///
/// check methods
///   clear
///   isEmpty
///   isNotEmpty
///   remove
void main() {
  test('tests about deleting in code ', () {
    dynamic root = MapList('{ "name":"zaza", "age": 7, "scores": [10,20,30]}');
    assert(root.scores[1] == 20);
    assert(root.scores.isNotEmpty);
    root.scores.remove(20);
    assert(root.scores[1] == 30);
    root.scores.clear();
    assert(root.scores.isEmpty);

    assert(root.length == 3);
    root.remove("scores");
    assert(root.length == 2);
    root.clear();
    assert(root.length == 0);
  });
}
