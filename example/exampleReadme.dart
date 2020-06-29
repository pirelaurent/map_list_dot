import 'package:map_list_dot/map_list_dot.dart';
import './example3Messages.dart';

/// In this example, we work a level higher with a knowledge base as root
/// In this base, we add new collections, one is myFriends
/// We receive messages that create new friends
///

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
 /// series of instructions in script text
  var script = [
    'persons=[]',
    '''persons.add({ "name": "Magellan", "firstName": "Fernando",
      "birthDate": { "day": 15,"month": 3,"year": 1480} 
      })
     ''',
    'persons.last.cards = {"mail": "ma.po.lo@china.com"})',
    'persons.last.cards.phone = "+99 01 02 03 04 05"'
  ];

  /*
   Create an empty knowledge base
   */
  dynamic myKB = MapListMap();
  // execute the scripts
  for (String line in script) myKB.exec(line);
  print( myKB.persons.last.cards.phone);
  // or still in script
  print(myKB.exec('persons.last.cards.phone'));



}


