import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

void universalDump(dynamic x, [String tab = ""]) {
  tab += '\t';
  switch (x.runtimeType) {
    case MapListList:
      for (var next in x) universalDump(next, tab);
      ;
      break;
    case MapListMap:
      x.forEach((key, value) {
        print('$tab$key: ');
        universalDump(value, tab);
      });
      break;
    default:
      print('$tab$x ');
  }
}

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('loop on a MapList by rank', () {
    print('---- this test will print values found while looping ');
    dynamic root = MapList();
    root.scores = <dynamic>[11, 12, 13];
    root.scores.add({"name": "zaza", "age": 15});
    root.scores[3].addAll({
      "interest": <dynamic>["vintage cars", "planets", "Krishnamurti"]
    });

    root.scores[3].interest.addAll([
      {
        "fetish numbers": [33, 66, 99]
      }
    ]);
    print(root);
    universalDump(root);
  });
}
