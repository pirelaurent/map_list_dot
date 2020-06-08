import 'dart:collection';
class A {

}

class AList extends A with ListMixin{

  @override
  operator []=(Object key, dynamic value) => null;

  @override
  operator [](Object keyIndex) =>null;
  get length => null;
  set length(int len) {
  }



}

class AMap extends A with MapMixin{

  void clear() {
  }

  get keys =>null;


  operator []=(dynamic key, dynamic value) {
  }

  operator [](Object key) {
  }

  @override
  void remove(Object key) {
  }


}


void main(){
  List l =[10,11,12,10];
  l.add(12);
  l.addAll([12,14,16]);
  print(l.length);
  print(l.isEmpty);
  l.remove(10);
  l.remove(100);
  print(l);
  l.clear();
  l.hashCode;
  l.ad

  Map m = {"name":"toto", "score": 20};
  print(m.length);
  print(m.isEmpty);
  m.remove("zaza");
  m.addAll({"other":"oo","more":"momo"});
  print(m);
  m.clear();
  m.hashCode;
  m.add

}





/*   NOT possible to merge two mixin map and list
error: The generative constructor 'MapList MapList([dynamic jsonInput])' expected, but factory found. (non_generative_constructor at [json_xpath] lib\src\map_list_list.dart:10)
error: The method 'add' isn't defined for the type 'MapList'. (undefined_method at [json_xpath] test\5_add&addAll_test.dart:28)

'MapMixin.cast' ('Map<RK, RV> Function<RK, RV>()') isn't a valid override of 'ListMixin.cast' ('List<R> Function<R>()'). (invalid_override at [json_xpath] test\sandBox.dart:2)
'MapMixin.forEach' ('void Function(void Function(dynamic, dynamic))') isn't a valid override of 'ListMixin.forEach' ('void Function(void Function(dynamic))'). (invalid_override at [json_xpath] test\sandBox.dart:2)
error: Missing concrete implementations of 'MapMixin.[]', 'MapMixin.[]=', 'getter MapMixin.keys', and 'setter List.length'. (non_abstract_class_inherits_abstract_member at [json_xpath] test\sandBox.dart:2)
 'MapMixin.map' ('Map<K2, V2> Function<K2, V2>(MapEntry<K2, V2> Function(dynamic, dynamic))') isn't a valid override of 'ListMixin.map' ('Iterable<T> Function<T>(T Function(dynamic))'). (invalid_override at [json_xpath] test\sandBox.dart:2)
 'MapMixin.remove' ('dynamic Function(Object)') isn't a valid override of 'ListMixin.remove' ('bool Function(Object)'). (invalid_override at [json_xpath] test\sandBox.dart:2)
 'MapMixin.removeWhere' ('void Function(bool Function(dynamic, dynamic))') isn't a valid override of 'ListMixin.removeWhere' ('void Function(bool Function(dynamic))'). (invalid_override at [json_xpath] test\sandBox.dart:2)
 'MapMixin.addAll' ('void Function(Map<dynamic, dynamic>)') isn't a valid override of 'ListMixin.addAll' ('void Function(Iterable<dynamic>)'). (invalid_override at [json_xpath] test\sandBox.dart:2)

 */