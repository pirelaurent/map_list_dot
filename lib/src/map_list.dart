import 'dart:mirrors';
import 'dart:convert';
import 'package:json_xpath/map_list_lib.dart';

/*
 Wrapper on any combined structure (maps and lists) to allow dot notation access.
 Useful to wrap a json as if it was already a set of classes.
 MapList is an ancestor of MapListList and MapListMap
   dedicated to respond respectively to "is List" or "is Map"
 */

class MapList {
  /*
   internal collection of Lists, Maps and leaf Values of any types
   (public as we separate subClasses in several files and no protected in Dart)
   */
  dynamic wrapped_json;

  // for more explicit error messages on [ ] calls, retain the name used
  static String lastInvocation;

/*
 set the root node on right type
 (root of a valid json could also be a List)
 can use a String or an already decoded json

 */

  factory MapList([dynamic jsonInput, bool initial = true]){
  // print('Factory ${jsonInput.runtimeType} ${jsonInput}');

    if (jsonInput is String) jsonInput = json.decode(jsonInput);
    else {
      if (initial) jsonInput = normaliseByJson(jsonInput) ;
    }

    if (jsonInput is List) return MapListList.json(jsonInput);

    if (jsonInput is Map) return MapListMap.json(jsonInput);
    // if empty, create a simple Map<dynamic, dynamic>
    return MapListMap.json(normaliseByJson({}));
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
 we define the operators and method here to be specialized later.
 we are mandatory on the MapMixing and ListMixin interface
 ------------- Shareable operators and methods -----------------
 */
/*
 MAP:   operator []=(dynamic key, dynamic value)
 LIST:   operator []=(Object key, dynamic value)  this one include previous
 operator []=(Object key, dynamic value) {
    print('must be overriden');
  }
 */


  get isEmpty=> wrapped_json.isEmpty;
  get isNotEmpty=> wrapped_json.isNotEmpty;
  clear()=> wrapped_json.clear();
  get hashCode => wrapped_json.hashCode;

/*
 -------------- specific method nice to have coulb be extended
  get keys =>null;           // from Map , return null for List
  add(dynamic value){} // from List. Can be uses on Map like an addAll


 */

/*
 -------------- incompatible methods
 MAP:  addAll(Map<dynamic,dynamic> other)
 LIST: addAll(Iterable <dynamic> iterable


 */

  /*
    dot notation try to find a property or a method on the MapList object
    To trap all demands, we use the noSuchMethod allowed by dart:mirrors

    When a composed name is called by in code, parts arrives one per one
    (due to the .) and each part returns a new MapList to allow the pursuit.

    When a composed name come from a script parameter,
    the script split the demand in individual parts and call noSuchMethod

    When there is .add(something) in code,
    it goes directly on the corresponding method on a Map or a List

   When in a script parameter

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
        /*
         if coming with script, param is a string
         if coming by code, param is already a constructed thing
         */
        param = normaliseByJson(param);
        //param = retype(param);
        if (param is String) param = adjustParam(param);
        wrapped_json[name] = param; // before []
        MapList.traceHash1 = wrapped_json[name].hashCode;
        return;
      };


        /*
         getter (if unknown, return null)
         the [ ] of this will create a MapList
         */

        /*
        can be followed by a direct .add or .addAll
         */

        var next = wrapped_json[name];
        if ((next is Map)||(next is List)) {
          MapList toReturn = MapList(next,false);
          return toReturn;
        }
          // simple data
          return this.wrapped_json[name];
        }
      //end setters

    }


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
 if between [ ] or between { } consider it's a json string to try
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
    // nothing special not yet returned
    return param;
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
      if (this is MapListList) where = where[rank];
      if (this is MapListMap) where = where[rank];
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
    bool checkNull = false; // to follow nullable ?
    // isolate a part up to a valid dot
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
      // found an existing part, recurse up to the end
      return next.script(script);
    }


    //--- recursive script has reached the end of the sentence

    /*
       end leaf reach expected data
       if leaf name is length check if a valid key in a map,
           otherwise returns the .length property
       if the leaf is name = xxx apply a setter with the receveid parameter
       */

    var parts = script.split("=");
    script = parts[0].trim();
    // no = sign, only one part
    if (parts.length == 1) {
      // in interpreter some method must not be sent to noSuchMethod
      // length could be a user entry
      if (script == "length") {
        if (wrapped_json is Map ) {
          if (wrapped_json["length"]!=null) return wrapped_json["length"];
        }
        return (this.wrapped_json.length);
      };

      /*
       look on .add(something) method in script
       */
      var foundAdd = reg_check_add.firstMatch(script);
      // add is significant for List when script
      if ((foundAdd != null) && ((this is MapListList)||(this is MapListMap)) ) {
        // what is the something part
        dynamic thingToAdd = foundAdd.group(0);
        // remove "add(   )" parts
        thingToAdd = thingToAdd.substring(4, thingToAdd.length - 1);
        thingToAdd = adjustParam(thingToAdd);

        // use cast to call right method
        if (this is MapListList){
          MapListList m = this;
          m.add(thingToAdd);
        }
        if (this is MapListMap ){
          MapListMap m = this;
          m.add(thingToAdd);
        }

        return;
      } // add

      /*
       check for addAll
       */
      var foundAddAll = reg_check_addAll.firstMatch(script);
      if ((foundAddAll != null) && ((this is MapListList)||(this is MapListMap))) {
        // what is the something part
        dynamic thingToAdd = foundAddAll.group(0);
        // remove "addAll(   )" parts
        thingToAdd = thingToAdd.substring(7, thingToAdd.length - 1);
        thingToAdd = adjustParam(thingToAdd);
        if (this is MapListList){
          MapListList m = this;
          m.addAll(thingToAdd);
        }
        if (this is MapListMap){
          MapListMap m = this;
          m.addAll(thingToAdd);
        }

        //this.addAll(thingToAdd);
        return;
      } // foundAll



      // try to get the entry named by last part
      dynamic value = getItemWithOptionalRank(script);

      // found a real entry value (or null)
      return value;
    } else
    // with parameters
    {
      // restore = necessary for invocation in noSuchMethod
      script = script + "=";
      var paramString = parts[1].trim();
      // script relay on noSuchMethod
      Invocation invocation = Invocation.setter(Symbol(script), paramString);
      noSuchMethod(invocation);
    } // item with end dot not found
  }




  /*
       to see something
       */

  @override
  String toString() {
    return wrapped_json.toString();
  }

  /*
   debug helpers
   */
  static void depiote(var someJson,[String key]){
    key=key??"";
    print(' ${someJson.runtimeType} (Map: ${someJson is Map} List: ${someJson is List}) ${someJson.hashCode} | $key: $someJson');
    if (someJson is Map){
      //print("Map : $key ${someJson.runtimeType}");
      someJson.forEach((key, value) {
        var suite = someJson[key];
        if (suite is Map) depiote(suite,key);
        if (suite is List) depiote(suite,key);
        // others continue
      });
      return;
    }
    if (someJson is List){
      //print('List : $key : ${someJson.runtimeType}');
      someJson.forEach((suite) {
        if (suite is Map) depiote(suite);
        if (suite is List) depiote(suite);
      });
    }
  }

  static dynamic normaliseByJson(var something){
    return json.decode(json.encode(something));
  }

  static var traceHash1 = 0;




}
