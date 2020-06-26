import 'package:map_list_dot/map_list_dot.dart';

/// a private place to test some dart syntax
void main(){
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

 List list =<dynamic>[10,11,12,"a"];
 print(list);
 dynamic x = MapList(list);
 print(x.runtimeType);
 print(x);
 print(x.wrapped_json);

 Map map = {"A":"AA", "B":"BB"};
 print(map);
 dynamic y = MapList(map);
 print(y.runtimeType);
 print(y);
 print (y.json);

}