import 'dart:mirrors';
import 'dart:convert';
import 'package:json_xpath/map_list_lib.dart';

/*
 Wrapper on a combined structure (maps and lists) to allow dot notation access.
 Useful to wrap a json as if it was already a set of classes
 MapList is an ancestor of MapListList and MapListMap
   dedicated to respond respectively to "is List" or "is Map"
 */

class MapList {
  /*
   internal collection of Lists, Maps and leaf Values of any types
   public as we separate subClasses in several files and no protected option
   */
  var wrapped_json;

  /*
    When creating entry on the fly and don't set any value,
    it defaults to a {} map (not on a null)
    This cas be checked by isEmpty which is overriden in MapListMap
   */
  bool get isEmpty => false;

  // for more explicit error messages on [ ] calls retain the name used
  static String lastInvocation;

/*
 set the root node on right type
 (root of a valid json could also be a List)
 can give a String or an already decoded json
 */

  factory MapList([dynamic jsonInput]) {
    if (jsonInput is String) jsonInput = json.decode(jsonInput);
    if (jsonInput is List) return MapListList.json(jsonInput);
    if (jsonInput is Map) return MapListMap.json(jsonInput);
    // if empty, create a simple Map<dynamic, dynamic>
    return MapListMap.json({});
  }

  /*
  common constructor. Just set the initial internal collection
  if intial json is made of homeneous data, can be a specialized json
  so, we generalize to allow further other types

  */
  MapList.json(dynamic jsonInput) {
    if (jsonInput is Map) {
      if (!(jsonInput.runtimeType is Map<dynamic, dynamic>)) {
        Map<dynamic, dynamic> map = Map.fromEntries(jsonInput.entries);
        jsonInput = map;
      }
    }
    wrapped_json = jsonInput;
  }

/*
 as we can call either a Map or a List behind a MapList
 we define the operators here to be specialized later.
 */

  operator [](Object key);

  operator []=(Object key, dynamic value);

  remove(Object key);

  /*
   when coming by interpreter with = xxxx we must analyse the string :
   "someString" -> someString
   'someString' -> someString
   String true -> boolean true
   String false -> boolean false
   any String valid as number -> number
   something between [ ] or { } -> json
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
 if between [ ] or between { } consider it's a json string
 */
    var found = reg_mapList.firstMatch(param);
    if (found != null) {
      try {
        var jsonVar = json.decode(found.group(0));
        return jsonVar;
      } catch (e) {
        print("** On invocation \"$lastInvocation\" : error json $e");
        // return something to avoid crash if some .notation after
        //if (param[0] == '[') return [];
        //if (param[0] == '{') return {};
        return null;
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
    get :   Symbol("name"): []
    set:    Symbol("name="): [quizine]
   */
    //print('invocation: $member: ${invocation.positionalArguments} ');
    String name;
    if (member is Symbol) {
      name = MirrorSystem.getName(member);
      MapList.lastInvocation = name;
      // setters
      if (name.endsWith('=')) {
        print(' on arrive avec $name');
        name = name.replaceAll("=", "");
        dynamic param = invocation.positionalArguments[0];
        if (param is String) param = adjustParam(param);
        this[name] = param;
        print(' on a créé this[name] $this');
        return;
      } else {
        // special words add for Lists
        var found = reg_add.firstMatch(name);
        if ((found != null) && (this is List)) {
          // remove add(   ) parts
          String sJson = found.group(0);
          sJson = sJson.substring(4, sJson.length - 1);
          // check if valid json string
          found = reg_mapList.firstMatch(sJson);
          if (found != null) {
            var aList = this as MapListList;
            aList.add(found.group(0));
            return;
          }
        }
        /*
         getter (if unknown, return null)
         the [ ] of this will create a MapList
         */
        print('ici on get $name sur $this');
        return this[name];
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
      RegExp("^[a-zA-Z0-9_]*(\\[[0-9]*(\\.\\.)?[0-9]*\\])?\\??\\.");

// [1..23]
  static final reg_brackets = RegExp("\\[[0-9]*\\]");

// json begin and end by [ ] or { }
  static final reg_mapList = RegExp("^[\\[\\{].*[\\}\\]]");

// static final detect add( some json )
  static final reg_add = RegExp("^add\\(.*\\)");

  /*   arrives here with book   book[1]   isbn
         is this item with brackets []?
          if yes, calculate rank
  */
  dynamic advanceInTree(String item) {
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
    if (where == null) return where;
    // found something correct : if a rank, apply it
    if (rank != null) {
      if (this is List) where = where[rank];
      if (this is Map) where = where[rank];
    }
    return where;
  }

  /*
   Allow some interpreter
   getter only
   */

  dynamic script(String script) {
    script = script.trim();
    //dynamic where = this;
    var item;
    // sample book[1].isbn
    // in case of some?.
    bool checkNull = false;
    var found = reg_scalp.firstMatch(script);
    // not an end of sentence : go on the road
    if (found != null) {
      item = found.group(0);
      // clean this part -> isbn
      script = script.replaceFirst(item, '');
      // remove the dot -> book[1]
      item = item.substring(0, item.length - 1);
      // check if a checknull option ?
      var c = item[item.length - 1];
      if (c == '?') {
        checkNull = true;
        item = item.substring(0, item.length - 1);
      }
      // let's check  the following
      var next = advanceInTree(item);
      if ((next == null) && checkNull) return null;
      // it's something correct (a MapList) go on
      return next.script(script);
    } else {
      /*
      no dot at the end
       end leaf return expected data
       special case : ends by .length
       if "length" is not a key , returns the .length property
       if ends with some = xxx apply a setter
       */

      var parts = script.split("=");

      script = parts[0].trim();
      // no = sign
      if (parts.length == 1) {
        // in interpreter some method must not be sent to noSuchMethod
        if (script == "isEmpty") return isEmpty;
        // length could be a user entry
        if (script == "length") {
          if (this is List) return (this.wrapped_json.length);
          if (this is Map) {
            if (this["length"] == null) return this.wrapped_json.length;
          }
          // otherwise leave it as standard search in case of [ ]
        }
        ;

        // try to get then entry named by last part
        dynamic value = advanceInTree(script);
        // found a real entry value
        return value;
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
