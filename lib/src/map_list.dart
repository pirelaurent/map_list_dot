import 'dart:mirrors';
import 'dart:convert';
import 'dart:io';

import 'package:map_list_dot/map_list_dot_lib.dart';

/// MapList storage is a simple Wrapper on any structure made of
/// Lists, Maps and leaf Values of any type, as or like a json structure
/// MapList allows access by a dot notation in code and with script

class MapList {
  /// internal data structure
  dynamic wrapped_json;

  /// for debug purpose
  static String lastInvocation;

  /// Constructor  via a factory returns the right map or list version
  /// jsonInput can be
  ///   nothing : create a map
  ///   a string to be  decoded by json
  ///   an already typed json or equivalent : create a map or a list
  /// initial is to retype the map & list in dynamic at first construct
  /// and to avoid to redo that in recursive construction.

  factory MapList([dynamic jsonInput, bool initial = true]) {
    // if empty, create a simple Map<dynamic, dynamic>
    if (jsonInput is Null) jsonInput = {};
    // try to decode a string and normalise structure
    if (jsonInput is String)
      jsonInput = trappedJsonDecode(jsonInput);
    else {
      if (initial) jsonInput = normaliseByJson(jsonInput);
    }
    ;

    if (jsonInput is List) return MapListList.json(jsonInput);
    if (jsonInput is Map) return MapListMap.json(jsonInput);
    return null;
    // if empty, create a simple Map<dynamic, dynamic>
    //return MapListMap.json(normaliseByJson({}));
  }

  /// real common constructor behind the factory
  MapList.json(dynamic jsonInput) {
    wrapped_json = jsonInput;
  }

  /// common methods for map ad list in front of the json data
  get isEmpty => wrapped_json.isEmpty;

  get isNotEmpty => wrapped_json.isNotEmpty;

  clear() => wrapped_json.clear();

  remove(var someEntry);

  @override
  String toString() {
    return wrapped_json.toString();
  }

/*
 -------------- incompatible methods not set to this level
 MAP:  addAll(Map<dynamic,dynamic> other)
 LIST: addAll(Iterable <dynamic> iterable
 */

  /// Trap all calls on this class, allowed by dart:mirrors
  /// aa.bb.cc comes first with a call to aa
  /// if aa is found this returns another MapList with the same json but shifted
  /// bb is then called on this new MapList, etc.
  ///
  /// [ ] operators are called directly by dart on the MapListMap or MapListList
  /// same thing for the .add and .addAll methods as they exist
  ///
  /// if the received Invocation has no assignment = something
  ///   the last step returns a data (ie getter)
  /// else the last step set the data (ie setter) and return nothing.
  ///
  /// see later that script reuses this internal mechanism to share code.

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var member = invocation.memberName;

    String name;
    if (member is Symbol) {
      name = MirrorSystem.getName(member);
      // ------------------ setters if equals
      if (name.endsWith('=') == false) {
        // special case if pseudo index in quotes at root: root.script(" '[255]' = 20");
        if (name == "''") {
          stderr.write(
              "** wrong name : index between quote. '[ ]'.  null returned \n");
          return null;
        }

        /// getter returns another MapList to continue or a data at the end
        /// but if it is a list, error
        if (this is MapListList) {
          stderr.write(
              '** List error: trying to get a key "$name" from a List. Null returned ');
          return null;
        }
        lastInvocation = name;
        var next = wrapped_json[name];

        if ((next is Map) || (next is List)) {
          return MapList(next, false);
        } else
          return this.wrapped_json[name];
      } else
      /* else this is a setter */ {
        name = name.replaceAll("=", "");
        dynamic param = invocation.positionalArguments[0];
        /* if coming with script, param is a string
           if coming by code, param is already a constructed thing
           in both cases something to do before insertion
         */
        param = normaliseByJson(param);

        if (param is String) param = adjustParam(param);
        /*
         from script, can arrive here some name[2] =
         when by code arrive name only then dart call [2] operator
         */
        var found = reg_brackets.firstMatch(name);
        if (found != null) {
          //found sample :rawRank-> [1]
          var rawRank = found.group(0);
          // clean the item -> book
          name = name.replaceAll(rawRank, '');
          // remove brackets  : rawRank ->1
          rawRank = rawRank.substring(1, rawRank.length - 1);
          int rank = num.tryParse(rawRank);
          if (!(rank == null)) {
            if ((rank >= 0) && (rank < wrapped_json[name].length)) {
              wrapped_json[name][rank] = param;
            } else {
              stderr.write('** index out of range on $name : $rank');
            }
            return;
          }
        }
        // not a [ ] index
        wrapped_json[name] = param;
        return;
      }
    }
  }

  /// Some regex to help
  /// \ is useful for some regex (doubled avoid to be trapped by dart)
  /// scalp : extract a front part of a script
  static final reg_scalp =
      RegExp("^[a-zA-Z0-9_]*(\\[[0-9]*(\\.\\.)?[0-9]*\\])?\\??\\.");

  // to allow trap of [toto]
  static final reg_scalp_relax =
      RegExp("^[a-zA-Z0-9_]*(\\[[a-zA-Z0-9_]*(\\.\\.)?[0-9]*\\])?\\??\\.");

  /// detect num index [123]
  static final reg_brackets = RegExp("\\[[0-9]*\\]");

  /// detect index [ any ]
  static final reg_brackets_relax = RegExp("\\[.*\\]");

  /// identify json script candidates : begin and end by [ ] or { }
  static final reg_mapList = RegExp("^[\\[\\{].*[\\}\\]]");

  /// trap .add method in a script
  static final reg_check_add = RegExp("^add\\(.*\\)");

  /// trap .addAll method in a script
  static final reg_check_addAll = RegExp("^addAll\\(.*\\)");

  /// script demands arrives here in one big string
  /// A front part is isolated and executed to find next position
  /// script call itself recursively for the following step
  /// On last step, depending of an equal sign, returns a data or set a data
  ///
  /// Empty script will return current position
  /// solo index '[1]' will return the [1] of current (if list)
  ///
  dynamic script([String aScript = ""]) {
    aScript = aScript.trim();

    var item;
    bool checkNull = false; // to follow nullable ?
    // isolate a part up to a valid dot
    var found = reg_scalp_relax.firstMatch(aScript);
    // not the end of sentence : go on the road
    if (found != null) {
      // get this part of the sentence book[1].isbn -> book[1].
      item = found.group(0);

      // clean up this beginning in script -> isbn
      aScript = aScript.replaceFirst(item, '');
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
      // even if no ? in case of wrong index:error was produced but continue
      if (next == null) return null;
      // found an existing part, recurse up to the end

      return next.script(aScript);
    }

    /*
       recursive script is now on  the end of the sentence
       end leaf reach expected data
       if leaf name is length check if a valid key in a map,
           otherwise returns the .length property
       if the leaf is name = xxx apply a setter with the receveid parameter
       */

    var parts = aScript.split("=");
    aScript = parts[0].trim();
    // no = sign : only one part
    if (parts.length == 1) {
      // length could be a user entry
      if (aScript == "length") {
        if (wrapped_json is Map) {
          if (wrapped_json["length"] != null) return wrapped_json["length"];
        }
        return (this.wrapped_json.length);
      }
      /*
       .add or .addAll method in script are called directly
       */
      var foundAdd = reg_check_add.firstMatch(aScript);
      // add is significant for List when script
      if ((foundAdd != null) &&
          ((this is MapListList) || (this is MapListMap))) {
        // what is the something part
        dynamic thingToAdd = foundAdd.group(0);
        // remove "add(   )" parts
        thingToAdd = thingToAdd.substring(4, thingToAdd.length - 1);
        thingToAdd = adjustParam(thingToAdd);
        if (this is MapListList) {
          MapListList m = this;
          m.add(thingToAdd);
        }
        if (this is MapListMap) {
          MapListMap m = this;
          m.add(thingToAdd);
        }
        return;
      } // add

      /*
       same for .addAll
       */
      var foundAddAll = reg_check_addAll.firstMatch(aScript);
      if ((foundAddAll != null) &&
          ((this is MapListList) || (this is MapListMap))) {
        // what is the something part
        dynamic thingToAdd = foundAddAll.group(0);
        // remove "addAll(   )" parts
        thingToAdd = thingToAdd.substring(7, thingToAdd.length - 1);
        thingToAdd = adjustParam(thingToAdd);
        if (this is MapListList) {
          MapListList m = this;
          m.addAll(thingToAdd);
        }
        if (this is MapListMap) {
          MapListMap m = this;
          m.addAll(thingToAdd);
        }
        return;
      } // foundAll

      /*
       the end was not .length .add or .addAll, find the entry in json
       */
      dynamic value = getItemWithOptionalRank(aScript);
      return value;
    } else {
      /* we are on a setter  with an = , will call noSuchMethod
        restore = sign  for invocation then invoke
       */
      aScript = aScript + "=";
      var paramString = parts[1].trim();

      /*
       If there is an index [ ], before calling assignment, verify validity
       but for new entry in a map, create even if not exists
       */

      var what = parts[0].trim();

      if (reg_brackets_relax.firstMatch(what) != null) {
        var atLeaf = getItemWithOptionalRank(what);
        // this index doesn't exist
        if (atLeaf == null) return;
      }
      if (aScript != null) {
        Invocation invocation = Invocation.setter(Symbol(aScript), paramString);
        noSuchMethod(invocation);
      }
      return;
    } // item with end dot not found
  }

  ///
  /// when using script, data in string has to become real values
  /// A string between quotes becomes a cleaned string
  /// string true/false becomes booleans
  /// string null becomes null
  /// any string (without quotes) are tested to be a valid number
  /// a string eligible to be a json-like structure is decoded
  /// if the json is not valid, returns a null and log a warning error
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
   if enclosed by  [ ] or { } consider it's a json string to try
   */
    var found = reg_mapList.firstMatch(param);
    if (found != null) {
      return trappedJsonDecode(found.group(0));
    }
    // nothing special not yet returned
    return param;
  }

  /// find an item by its string name 'name' or name[rank]
  /// uses the common code by invokink noSuchMethod on the MapList
  /// can generate an error if rank is not valid and no nullable option

  dynamic getItemWithOptionalRank(String item) {
    dynamic where;
    var originalItem = item;
    int rank;
    bool withBrackets = false;
    var rawRank;
    var found = reg_brackets_relax.firstMatch(item);
    if (found != null) {
      withBrackets = true;
      //found sample :rawRank-> [1]
      rawRank = found.group(0);

      // clean the item -> book
      item = item.replaceAll(rawRank, '');
      // remove brackets  : rawRank ->1
      rawRank = rawRank.substring(1, rawRank.length - 1);
      rank = num.tryParse(rawRank);
    }
    /*
     in rare case where the root is a List,
     some calls can arrive empty or as pure index '[2]'
     in this case apply to current
     */
    if (item == "") {
      where = this;
    } else {
      // first try to get an access to the item
      Invocation invocation = Invocation.getter(Symbol(item));
      where = noSuchMethod(invocation);

    }

    if (where == null) return where;
    // found something correct : if a valid rank, apply it
    if (withBrackets) {
      if (rank != null) {
        //if (this is MapListList) return where[rank];
        //if (this is MapListMap)  return where[rank];
        if (where is MapListList) return where[rank];
        stderr.write(
            '** wrong index [$rank]. $originalItem is not a List. get: null returned ; set: no change\n');
        return null; // previously where
      } else {
         print('PLA: $rawRank');
        stderr.write(
            "** bad index : $originalItem . get: null returned. set: no change \n");
        // wrong demand into [ ]
        return null;
      }
    } else // no brackets
      return where;
  }

  /// the most simple,  efficient and sure method to align the types
  static dynamic normaliseByJson(var something) {
    return trappedJsonDecode(json.encode(something));
  }

  /// choose to return null rather to crash
  static trappedJsonDecode(String something) {
    try {
      return json.decode(something);
    } catch (e) {
      stderr.write('** wrong data. MapList will return null :  $e ');
      return null;
    }
  }
}
