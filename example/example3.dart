import 'package:map_list_dot/map_list_dot.dart';
import './example3Messages.dart';

/// In this example, we work a level higher with a knowledge base as root
/// In this base, we add new collections, one is myFriends
/// We receive messages that create new friends
///

class Knowledge extends MapListMap {
  Knowledge([someInit]) : super(someInit);
/// most simplified event listener to apply messages
  void receiveMessage(var aMessage) {
    exec(aMessage);
  }
}

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  /*
   Create an empty knowledge base
   Knowledge is a MapListMap
   with a method receiveMessage(String)
   */
  dynamic myKB = Knowledge();
  // send a first message that create a new collection 'persons'
  myKB.receiveMessage('persons=[]');
  // simulate arrival of a large message to set data
  myKB.receiveMessage(fakeMessage1());
  myKB.receiveMessage(fakeMessage2());
  /*
   as in example 1 or 2, can use dot notation in dart
   Here we loop on all known persons
   */
  for (var p1 in myKB.persons) {
    p1.age = (DateTime.now().year - p1.birthDate.year);
    print('${p1.firstName} ${p1.name} will have now ${p1.age} years');
    // now add some contacts without creating new class
    print(
        'He can be contacted by ${p1.cards.length} ways:');
    for (var aCard in p1.cards) {
      var mail = aCard.mail ??= '';
      var phone = aCard.phone ??= '';
      print('\t - mail:$mail \n\t   phone: $phone');
    }
    print('-----');
  }
}


