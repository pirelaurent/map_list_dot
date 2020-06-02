import 'dart:mirrors';
import 'dart:convert';
import 'package:json_xpath/map_list_lib.dart';

/*
 Wrapper on a combined structure (maps and lists) to allow dot notation access.
 Useful to wrap a json as if it was already a set of classes
 MapList is an ancestor of MapListList and MapListMap
   both dedicated to respond respectively to "is List" or "is Map"

 */
class MapList {
  /*
   internal collection of Lists, Maps and leaf Values
   as we separate classes in several files, cannot stay private _json
   */
  var wrapped_json;

  get getJson => wrapped_json;

/*
 set the root node on right type
 (root of a valid json could also be a List)
 can give a String or an already decoded json
 */

  factory MapList(dynamic jsonInput) {
    if (jsonInput is String) jsonInput = json.decode(jsonInput);
    if (jsonInput is List) return MapListList.json(jsonInput);
    if (jsonInput is Map) return MapListMap.json(jsonInput);
    return MapListBlackHole.json('');
  }

  /*
  common constructor. Just set the internal collection
  */
  MapList.json(dynamic jsonInput) {
    wrapped_json = jsonInput;
  }

/*
 as we can call either a Map or a List behind a MapList
 we define the operators here to be specialized later.
 */

  operator [](Object key);

  operator []=(Object key, dynamic value);

  /*
   when coming by interpreter, the string is not all time the good type
   */
  dynamic adjustParam(var param) {
    // if between ' or between " extract and leaves as String
    if ((param[0] == '"') && param.endsWith('"')) {
      return param.substring(1, param.length - 1);
    }
    if ((param[0] == "'") && param.endsWith("'")) {
      return param.substring(1, param.length - 1);
    }
    if (param == "true") return true;
    if (param == "false") return false;

    var number = num.tryParse(param);
    if (number != null) return number;
/*
 if betwwen [ ] oer between { } consider it's a json string
 */
    var found = reg_mapList.firstMatch(param);
    if (found != null) {
      try {
        var jsonVar = json.decode(found.group(0));
        return jsonVar;
      } catch (e) {
        print("error parsing json string $e");
        // return something to avoid crash if some .notation after
        if (param[0] == '[') return [];
        if (param[0] == '{') return {};
      }
    }
    // nothing special

    return param;
  }

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
    print('noSuchMethod: $member: ${invocation.positionalArguments}');
    String name;
    if (member is Symbol) {
      name = MirrorSystem.getName(member);
      // setters
      if (name.endsWith('=')) {
        name = name.replaceAll("=", "");
        dynamic param = invocation.positionalArguments[0];
        if (param is String) param = adjustParam(param);
        this[name] = param;
        //return nothing after a setter
      } else {
        // getter
        if (this[name] != null) return this[name];
        // to allow continuation return a blackHole
        return MapListBlackHole.json("");
      }
    }
  }

/*
scalp the first part of path before a . toto.  rip[12].
 from beginning : letter, digit in any number.
  end by a dot
 ( optional [ first .. last   ] allowed for future extension )
 */
  static final reg_scalp =
      RegExp("^[a-zA-Z0-9_]*(\\[[0-9]*(\\.\\.)?[0-9]*\\])?\\.");

// [1..23]
  static final reg_brackets = RegExp("\\[[0-9]*\\]");

// json begin and end by [ ] or { }
  static final reg_mapList = RegExp("^[\\[\\{].*[\\}\\]]");

  dynamic advanceInTree(String item) {
    /*   arrives here with book   book[1]   isbn
         is this item with brackets []?
          if yes, calculate rank
     */
    dynamic where;
    int rank;
    var found = reg_brackets.firstMatch(item);
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

    var found = reg_scalp.firstMatch(script);
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
          return (wrapped_json.length);
        }
        return where;
      } else
      // with parameters
      {
        // restore = necessary for invocation
        script = script + "=";
        var paramString = parts[1].trim();

        Invocation invocation = Invocation.setter(Symbol(script), paramString);
        noSuchMethod(invocation);
      } // item with end dot not found
    }
  }

  @override
  String toString() {
    return wrapped_json.toString();
  }
}
