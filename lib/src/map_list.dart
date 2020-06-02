import 'dart:collection';
import 'dart:mirrors';
import 'dart:convert';

/*
 Wrapper on a combined structure (maps and lists) to allow dot notation access.
 Useful to wrap a json as if it was already a set of classes
 MapList is an ancestor of MapListList and MapListMap
   both dedicated to respond respectively to "is List" or "is Map"

 */
class MapList {
  // internal collection of Lists, Maps and leaf Values
  var _json;

/*
 set the root node on right type
 (root of a valid json could also be a List)
 can give a String or an already decoded json
 */

  factory MapList(dynamic jsonInput) {
    if (jsonInput is String) jsonInput = json.decode(jsonInput);
    if (jsonInput is List) return MapListList.json(jsonInput);
    if (jsonInput is Map) return MapListMap.json(jsonInput);
  }

  /*
  common constructor. Just set the internal collection
  */
  MapList.json(dynamic json) {
    _json = json;
  }

/*
 as we can call either a Map or a List behind a MapList
 we define the operators here to be specialized later.
 */

  operator [](Object key);

  operator []=(Object key, dynamic value);

  /*
   invocation.memberName: Symbol("root")
   */
  @override
  dynamic noSuchMethod(Invocation invocation) {
    var member = invocation.memberName;
    /*
    print('noSuchMethod: $member: ${invocation.positionalArguments}');
    get :   Symbol("name"): []
    set:    Symbol("name="): [quizine]
   */
    //print('noSuchMethod: $member: ${invocation.positionalArguments}');
    String name;
    if (member is Symbol) {
      name = MirrorSystem.getName(member);
      if (name.endsWith('=')) {
        name = name.replaceAll("=", "");
        dynamic param = invocation.positionalArguments[0];

        this[name] = param;

        return null;
      } else
        return this[name];
    }
  }

/*
 from beginning
 letter, digit in any number
 optional [ digits optional .. digits   ]
 end by a dot
 */
  static final scalp =
      RegExp("^[a-zA-Z0-9_]*(\\[[0-9]*(\\.\\.)?[0-9]*\\])?\\.");

// [1..23]
  static final brackets = RegExp("\\[[0-9]*\\]");

  dynamic advanceInTree(String item) {
    /*   arrives here with book   book[1]   isbn
         is this item with brackets []?
          if yes, calculate rank
     */
    dynamic where;
    int rank;
    var found = brackets.firstMatch(item);
    if (found != null) {
      //found sample :rawRank-> [1]
      var rawRank = found.group(0);
      // clean the item -> book
      item = item.replaceAll(rawRank, '');
      // remove brackets  : rawRank ->1
      rawRank = rawRank.substring(1, rawRank.length - 1);
      rank = num.tryParse(rawRank);
    }
    // first get the named part
    Invocation invocation = Invocation.getter(Symbol(item));
    where = noSuchMethod(invocation);
    // if a rank, apply it
    if (rank != null) where = where[rank];
    return where;
  }

  /*
   Allow some interpreter
   getter only
   */

  dynamic interpret(String script) {
    script = script.trim();
    dynamic where = this;
    var item;
    // sample book[1].isbn

    var found = scalp.firstMatch(script);
    if (found != null) {
      item = found.group(0);
      // clean this part -> isbn
      script = script.replaceFirst(item, '');
      // remove the dot -> book[1]
      item = item.substring(0, item.length - 1);
      // let's responds the following
      return advanceInTree(item).interpret(script);
    } else {
      /*
      no dot at the end
       end leaf return expected data
       special case : ends by .length
       if "length" is not a key , returns the .length property
       if ends with some = xxx apply a setter
       */

      var parts = script.split("=");
      // restore the = for the invocation
      script = parts[0].trim();
      // no = sign
      if (parts.length == 1) {
        dynamic where = advanceInTree(script);

        if (script == "length" && where == null) {
          return (_json.length);
        }
        return where;
      } else
      // with parameters
      {
        // restore = necessary for invocation
        script = script + "=";
        var paramString = parts[1].trim();

        dynamic param = paramString;
        var number = num.tryParse(paramString);
        if (number != null) param = number;
        if (paramString == "true") param = true;
        if (paramString == "false") param = false;

        Invocation invocation = Invocation.setter(Symbol(script), param);
        noSuchMethod(invocation);
        // it's ok here, but outside not set . direct assignment is ok.
        print('after invocation : $this  ');

      } // item with end dot not found
    }
  }
}

/*
 a MapListList is a List as it realizes ListMixin

 */
class MapListList extends MapList with ListMixin {
  MapListList.json(dynamic json) : super.json(json);

  get length => _json.length;

  set length(int len) {
    _json.length = len;
  }

  /*
   Setter in a list position.
   Must be an integer, but common operator is more general.
   */
  @override
  operator []=(Object key, dynamic value) {
    //if (key is! int) );
    if (key is int) {
      _json[key] = value;
    } else {
      print('******** warning call List[] with a ${key.runtimeType}');
      // do nothing
    }
  }

  @override
  operator [](Object key) {
    if (key is int) {
      var next = _json[key];
      if (next is List || next is Map)
        return MapList(next);
      else
        return next;
    }
    return null;
  }

  void add(dynamic value) {
    _json.add(value);
  }

  @override
  String toString() {
    return _json.toString();
  }
}

/*
 Map wrapper
 */
class MapListMap extends MapList with MapMixin {
  MapListMap.json(dynamic json) : super.json(json);

  get keys => _json.keys;

//type 'double' is not a subtype of type 'String' of 'value'
  operator []=(Object key, dynamic value) => {_json[key] = value};

  operator [](Object key) {
    var next = _json[key];
    if (next is List || next is Map)
      return MapList(next);
    else
      return next;
  }

  void clear() {
    _json.clear();
  }

  void remove(var key) {
    _json.remove(key);
  }
}
