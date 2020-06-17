import 'package:map_list_dot/map_list_dot.dart';


void main(){
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });



  dynamic store = MapList();
  store.book = ["A","B","C"];
  print(store.book[400]);                 // -> null;
  store.book[400]?.author = "zaza";       //
}