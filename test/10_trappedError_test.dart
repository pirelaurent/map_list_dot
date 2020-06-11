import 'package:map_list_dot/map_list_dot_lib.dart';
import 'package:test/test.dart';



void main(){
  print('------------------  These test must write trapped errors on stdErr -------------');

  test( 'wrong json in constructor ',(){
    dynamic root = MapList('{"this": is not a[12] valid entry }');
    assert(root == null);
  });

  test( 'wrong json in assignment  ',(){
    dynamic root = MapList({"name":"zaza"});
    root.script('name = [10,11,12,]');
    assert(root.name == null);
  });

  test( 'applying index on a map  ',(){
    dynamic root = MapList({"name":"zaza", "age":12});
    assert(root.script('name[0].value')== null);
    // same with trying to change a value
    // root.name[0] = "lulu"; cannot be done in code
    root.script('name[0]= "lulu"');
    assert(root.name == "zaza");
/*
NoSuchMethodError: Class 'String' has no instance method '[]='.
Receiver: "zaza"
Tried calling: []=(0, "lulu")
 */
  });


}