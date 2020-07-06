import 'dart:convert';

///
/// internal tests made on the way to understand Type conflicts

/// recursive analysis
void depiote(var someJson, [String key]) {
  key = key ?? "";
  if (someJson is Map) {
    print("Map : $key ${someJson.runtimeType}");
    someJson.forEach((key, value) {
      var suite = someJson[key];
      if (suite is Map) depiote(suite, key);
      if (suite is List) depiote(suite, key);
      // other continue
    });
    return;
  }
  if (someJson is List) {
    print('List : $key : ${someJson.runtimeType}');
    someJson.forEach((suite) {
      if (suite is Map) depiote(suite);
      if (suite is List) depiote(suite);
    });
  }
}

///
/// to be ataunomous from MapList
dynamic normaliseByJson(var something) {
  return json.decode(json.encode(something));
}

/*
 about soundness
 map.cast is a wrapper that check at every call
 map.from is a copy in a new map


 */

void main() {
  var map = {};
  print(map.runtimeType); // default : _InternalLinkedHashMap<dynamic, dynamic>
  var list = [];
  print(list.runtimeType); // default : List<dynamic>

  String jsonMap = '{}';
  var j1 = json.decode(jsonMap);
  print(j1.runtimeType); // json _InternalLinkedHashMap<String, dynamic>

  String jsonList = '[]';
  var j2 = json.decode(jsonList);
  print(j2.runtimeType); // List <dynamic>

  print('----------------------------');

  var direct1 = {
    "name": "toto",
    "color": "blue"
  }; // _InternalLinkedHashMap<String, String>
  depiote(direct1);
  // cannot add age:20 to direct1 as <String,String>
  var direct2 = {
    "name": "toto",
    "color": "blue",
    "age": 20
  }; //Map : _InternalLinkedHashMap<String, Object>
  depiote(direct2);
  direct2 = {
    "name": "toto",
    "color": "blue",
    "age": 20,
    "scores": [11, 12, 13]
  }; //List : List<int>
  depiote(direct2);
  // direct2["scores"].add("pouet"); the method add is not defined for Object
  //----------------------- try the same with dynamic
  var direct3 = {
    "name": "toto",
    "color": "blue",
    "age": 20
  }; //Map : _InternalLinkedHashMap<String, Object>
  depiote(direct3);
  direct3 = {
    "name": "toto",
    "color": "blue",
    "age": 20,
    "scores": [11, 12, 13]
  }; //List : List<int>
  depiote(direct3);
  //direct3["scores"].add("pouet"); //method add is allowed if direct3 is dynamic, but  type 'String' is not a subtype of type 'int' of 'value'

  print(
      "------------------------- print all in json --------------------------------");

  var json1 = json.decode(json.encode({
    "name": "toto",
    "color": "blue"
  })); // Map : _InternalLinkedHashMap<String, dynamic>
  depiote(json1);
  var json2 = json.decode(json.encode({
    "name": "toto",
    "color": "blue",
    "age": 20
  })); // Map : _InternalLinkedHashMap<String, dynamic>
  depiote(json2);

  var json3 = json.decode(json.encode({
    "name": "toto",
    "color": "blue",
    "age": 20,
    "scores": [11, 12, 13]
  })); //List : List<dynamic>
  depiote(json3);
  // here json3 can stay as var
  json3["scores"].add("pouet");
  depiote(json3);

  print('------------------ try to recast ---------------');
  var cast1 = {
    "name": "toto",
    "color": "blue",
    "age": 20,
    "scores": [11, 12, 13]
  };
  depiote(cast1); // _InternalLinkedHashMap<String, Object> // List<int>
  print(cast1["scores"].runtimeType);
  Map<String, dynamic> cast2 =
      cast1.cast<String, dynamic>(); //CastMap<String, Object, String, dynamic>
  depiote(cast2);
  List lili = cast1["scores"];
  List<dynamic> lili2 =
      lili.cast<dynamic>(); //CastList<int, dynamic> ?? à double entrée  ??
  print(lili2.runtimeType);
  //---------- pas les mêmes objets, pas les mêmes types
// et ça conserve les contraintes d'origine sur la partie int
  //  lili2.add("{}");
  print(
      '---------------------------- test with normaliseByJson --------------------');
  var norm1 = normaliseByJson({
    "name": "toto",
    "color": "blue"
  }); // Map :  _InternalLinkedHashMap<String, dynamic>
  depiote(norm1);
  var norm2 = normaliseByJson({"name": "toto", "color": "blue", "age": 20});
  depiote(norm2);
  norm2 = normaliseByJson({
    "name": "toto",
    "color": "blue",
    "age": 20,
    "scores": [11, 12, 13]
  }); //List : List<int>
  depiote(norm2);
  // when adding directly, this create a native Map :  _InternalLinkedHashMap<String, String>
  norm2["scores"].add({"note": "some note"});
  depiote(norm2);

/*




 */
}
