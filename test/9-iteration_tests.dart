import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';

void main(){
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('loop on a MapList ',(){
    dynamic root = MapList();
    root.scores = [11,12,13];
    root.scores.add ({"name":"zaza","age":15});
    // MapList does't implements iterable. The loop must be done by index:
    for (int i=0; i<root.scores.length;i++){
      if (root.scores[i] is num) print(root.scores[i]);
      if (root.scores[i] is MapListMap) print(root.scores[i].name);
    }
  }
  );

}