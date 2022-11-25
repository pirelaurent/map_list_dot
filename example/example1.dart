import 'package:map_list_dot/map_list_dot.dart';

/// Quick prototype with only json as class descriptor
/// Here we create a MapListMap as we know we will start with a Map
/// Then we create a free instance of this data class and manipulate its data

void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  /*
    simplest way to create an instance of a free data object
   */

  dynamic p1 = MapListMap({
    "name": "Polo",
    "firstName": "marco",
    "birthDate": {"day": 15, "month": 9, "year": 1254}
  });
  /*
    we manipulate its data as class properties
   */
  print('${p1.firstName} ${p1.name}:');
  print(
      '${p1.firstName} ${p1.name} have now ${DateTime.now().year - p1.birthDate.year} years');
  /*
   add dynamically and freely a new property in this instance.
   */
  p1.age = (DateTime.now().year - p1.birthDate.year);
  // and use it
  print('He will have now ${p1.age} years');
  /*
   now add some contacts with pure dart structure
   First line will add a 'property' cards as a List
   Then we add several maps to this list.
   New 'properties' in the maps are reachable in dot notation
   Last is a keyword for the last element of a list
   */

  p1.cards = [];
  p1.cards.add({
    "mail": "ma.po.lo@china.com",
  });
  p1.cards.last.phone = "+99 01 02 03 04 05";
  print(p1.cards.last.mail);
  p1.cards.add({"mail": "marco@venitia.com", "phone": "+00 99 98 97 96 95"});
  /*
  use these new properties in code, including loops
  */
  print(
      '${p1.firstName} ${p1.name} can be contacted with ${p1.cards.length} business cards:');
  for (var aCard in p1.cards) {
    var mail = aCard.mail ??= '';
    var phone = aCard.phone ??= '';
    print('\t - mail:$mail \n\t   phone: $phone ');
  }
}
