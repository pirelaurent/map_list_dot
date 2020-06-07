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
    wrapped_json = jsonInput;
  }

/*
 as we can call either a Map or a List behind a MapList
 we define the operators here to be specialized later.
 */

  operator [](Object key);

  operator []=(Object key, dynamic value);

  remove(Object key);

  add(var something);

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

    if (param == 'null') return null;

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
        return null;
      }
    }
    // nothing special
    return param;
  }

  /*
    Here arrives the name of the data and the data when is with =
    When a composed name is in code, parts arrives one per one (due to the .)
    When a composed name is sent to script, script split it
    and call noSuchMethod part per part.

    When there is .add(something) in code,
    it goes directly on the corresponding method
    But when in script, this arrives here as a .add(something)

   */
  @override
  dynamic noSuchMethod(Invocation invocation) {
    var member = invocation.memberName;

    /*
    get :   Symbol("name"): []
    set:    Symbol("name="): [quizine]
    set for list extension: .add(something)
    set for Map fusion : .addAll(something)

   */
    //print('invocation: $member: ${invocation.positionalArguments} ');
    String name;
    if (member is Symbol) {
      name = MirrorSystem.getName(member);
      // to facilitate debug message, notice that place
      MapList.lastInvocation = name;

      // ------------------ setters with equals
      if (name.endsWith('=')) {
        name = name.replaceAll("=", "");
        dynamic param = invocation.positionalArguments[0];

        param = retype(param);
        if (param is String) param = adjustParam(param);

        this[name] = param;
        return;
      }
      ;
      /*
      *** remember only in script access ***
       no =, but could be a setter with add(something) check it
       the something arrives here onmy for script and in string
       */

      var foundAdd = reg_check_add.firstMatch(name);

      // add is significant for List
      if ((foundAdd != null) && ((this is List)||(this is Map)) ) {
        // what is the something part
        dynamic thingToAdd = foundAdd.group(0);
        // remove "add(   )" parts
        thingToAdd = thingToAdd.substring(4, thingToAdd.length - 1);
        thingToAdd = adjustParam(thingToAdd);
        this.add(thingToAdd);
        return;
      }

      var foundAddAll = reg_check_addAll.firstMatch(name);
      if ((foundAddAll != null) && (this is Map)) {
        // what is the something part
        dynamic thingToAdd = foundAddAll.group(0);
        // remove "addAll(   )" parts
        thingToAdd = thingToAdd.substring(7, thingToAdd.length - 1);
        thingToAdd = adjustParam(thingToAdd);
        this.add(thingToAdd);
        return;
      }

        /*
       was not .add, so it's a data
         getter (if unknown, return null)
         the [ ] of this will create a MapList
         */
      return this[name];
      //end setters

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

// static final detect add( some json for list an map )
  static final reg_check_add = RegExp("^add\\(.*\\)");
  static final reg_check_addAll = RegExp("^addAll\\(.*\\)");

  /*   arrives here with book   book[1]   isbn
         is this item with brackets []?
          if yes, calculate rank
  */
  dynamic getItemWithOptionalRank(String item) {
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
    var item;
    // to follow nullable
    bool checkNull = false;
    // isolate a part up to a valid .
    var found = reg_scalp.firstMatch(script);
    // not the end of sentence : go on the road
    if (found != null) {
      // get this part of the sentence book[1].isbn -> book[1].
      item = found.group(0);
      // clean up this beginning in script -> isbn
      script = script.replaceFirst(item, '');
      // remove the dot -> book[1]
      item = item.substring(0, item.length - 1);
      // check if a checknull option ? at the end
      var lastChar = item[item.length - 1];
      if (lastChar == '?') {
        checkNull = true;
        // remove the ?
        item = item.substring(0, item.length - 1);
      }

      // let's check if the item exists
      var next = getItemWithOptionalRank(item);
      if ((next == null) && checkNull) return null;
      // it's something correct (a MapList) go on on the script

      return next.script(script);
    }
    //--- recursive script has reached the end of the sentence

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
      dynamic value = getItemWithOptionalRank(script);
      // found a real entry value (or null)
      return value;
    } else
    // with parameters
    {
      // restore = necessary for invocation in noSuchMethod
      script = script + "=";
      var paramString = parts[1].trim();

      Invocation invocation = Invocation.setter(Symbol(script), paramString);
      noSuchMethod(invocation);
    } // item with end dot not found
  }

  /*
   retypes
   */
  dynamic retype(dynamic something) {
    if (something is Map) {
      if (!(something.runtimeType is Map<dynamic, dynamic>)) {
        //print('found bad Map in List ${something.runtimeType} $something');
        Map<dynamic, dynamic> map = Map.fromEntries(something.entries);
        something = map;
      }
    }

    if (something is List) {
      if (!(something.runtimeType is List<dynamic>)) {
        //print('found a bad List in List ${something.runtimeType} $something');
        List<dynamic> list = [];
        something.forEach((element) {
          list.add(element);
        });
        something = list;
      }
    }

    // return as is
    return something;
  }

  /*
       to see something
       */

  @override
  String toString() {
    return wrapped_json.toString();
  }
}
