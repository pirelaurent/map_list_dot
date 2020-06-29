
import 'package:map_list_dot/map_list_dot.dart';


/// quick prototype with only json as class descriptor
/// Here we precise we create a MapListMap as we know the json
/// Otherwise, let the generix MapList factory decide what is to create,
/// a MapListList or a MapListMap.
///

void main(){
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  /*
    simplest way to create an instance of a pseudo class
   */

  dynamic p1 = MapListMap({
  "name": "Polo",
  "firstName": "marco",
  "birthDate": {
  "day": 15,
  "month": 9,
  "year": 1254
  }});
  // then use the dot notation as if it is a classical class with get & set
 print('${p1.firstName} ${p1.name}:');
  print('${p1.firstName} ${p1.name} have now ${DateTime.now().year - p1.birthDate.year} years');
 // create new dynamic data to this object
  p1.age = (DateTime.now().year - p1.birthDate.year);
 // use it as a property
  print('He will have now ${p1.age} years');
  /*
   now add some contacts with pure dart structure
   First line will add a 'property' contact as a List
   Then we add maps to this list.
   New 'properties' in the maps are now reachable directly
   */


  p1.cards = [];
  p1.cards.add({
    "mail": "ma.po.lo@china.com",
  });
  p1.cards.last.phone = "+99 01 02 03 04 05";
  print(p1.cards.last.mail);
  p1.cards.add( {
    "mail": "marco@venitia.com",
    "phone": "+00 99 98 97 96 95"
  });
 /*
  use new properties in code.
  As we reach them through a root of type MapList, it returns at each step
  a new MapListList or MapListMap, allowing the chaining.
  */
  print('${p1.firstName} ${p1.name} can be contacted with ${p1.cards.length} business cards:');
  for (var aCard in p1.cards ){
    var mail = aCard.mail??='';
    var phone = aCard.phone??='';
    print('\t - mail:$mail \n\t   phone: $phone ');
  }

}