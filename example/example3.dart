import 'package:map_list_dot/map_list_dot.dart';
import './example3Messages.dart';

/// In this example, we work a level higher with a knowledge base as root
/// In this base, we can add freely new collections, one is myFriends
/// To demonstrate interpreter, we simulate reception of messages
/// These messages are evaluated and create or modify data
///

class Knowledge extends MapListMap {
  Knowledge([someInit]) : super(someInit);
/// most simplified event listener to apply messages
  void receiveMessage(var aMessage) {
    eval(aMessage);
  }
}

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  /*
   Create an empty knowledge base.
   A first message creates a collection named persons
   Following messages will create person's data
   */
  dynamic myKB = Knowledge();
  // send a first message that creates a new collection 'persons'
  myKB.receiveMessage('persons=[]');
  // simulate arrival of some messages to set data
  myKB.receiveMessage(fakeMessage1());
  myKB.receiveMessage(fakeMessage2());
  /*
   as in example 1 or 2, can use dot notation in dart
   Here we loop on all known persons
   */
  for (var someone in myKB.persons) {
    someone.age = (DateTime.now().year - someone.birthDate.year);
    print('${someone.firstName} ${someone.name} will have now ${someone.age} years');
    // now add some contacts without creating new class
    print(
        'He can be contacted by ${someone.cards.length} ways:');
    for (var aCard in someone.cards) {
      var mail = aCard.mail ??= '';
      var phone = aCard.phone ??= '';
      print('\t - mail:$mail \n\t   phone: $phone');
    }
    print('-----');
  }
}


