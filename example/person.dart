import 'package:map_list_dot/map_list_dot.dart';
/// to create a class, choose the root as a MapListMap or a MapListList
/// more generaly choose a MapListMap as first level :
class Person extends MapListMap{
 // default constructors are always the same , just fill in the json
 Person(some):super(some);

 /// now, all data are available, including for methods .
 /// use me. to access to this dynamically
 int get age {
 return (DateTime.now().year - me.birthDate.year);
 }
}
