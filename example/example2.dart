
import 'package:map_list_dot/map_list_dot.dart';

/// This new example defines an intermediary class Person to allow methods
/// But the properties of Person are still laying in a dynamic json
/// And accessed in dot notation as classical properties
/// The class just extends a MapListMap to profit of dot notation
///
class Person extends MapListMap{
  Person(some):super(some);
  /*
    the difference with example1 is that
    we replace the instance new data age by a method in the class Person.
    'me' is 'this' declared as dynamic in order to allow dot notation inside the class .
   */
  int get age {
    return (DateTime.now().year - me.birthDate.year);
  }

  // of course any other method can be designed
  bool isImportant(int threshold){
    return (me.cards.length > threshold);
  }
}

/// create persons  .
/// Think about using dynamic to allow compiler to accept unknown properties
///
void main(){
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  /*
   now create instances of Person
   */

  dynamic p1 = Person({
  "name": "Polo",
  "firstName": "marco",
  "birthDate": {
  "day": 15,
  "month": 9,
  "year": 1254,
  },
    // to vary we create the cards list in the json, not later as in example1
    "cards": []
  });


 print('${p1.firstName} ${p1.name} will have now ${p1.age} years');
 /*
   now add some contacts with direct inline structure
   without creating a specific class for that
  */
  p1.cards.add({
    "mail": "ma.po.lo@china.com",
    "phone": "+99 01 02 03 04 05"
  });
  p1.cards.add( {
    "mail": "marco@venitia.com",
    "phone": "+00 99 98 97 96 95"
  });

  p1.cards.add( {
    "mail": "polo@water.com",
     });
  /*
   same as example 1 : use dot notation and loops
   */

  print('${p1.firstName} ${p1.name} can be contacted by ${p1.cards.length} ways:');
  for (var aCard in p1.cards ){
    var mail = aCard.mail??='';
    var phone = aCard.phone??='';
    print('\t mail:$mail \n\t phone: $phone');
  }
   if (p1.isImportant(2)) print('\t ** VIP **');
}