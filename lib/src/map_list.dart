import 'dart:mirrors';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:map_list_dot/map_list_dot.dart';

/// MapList storage is a simple Wrapper on any structure made of
/// Lists, Maps and leaf Values of any type, as or like a json structure
/// MapList allows access by a dot notation in code and with script

class MapList {
  static final log = Logger('MapList');

  /// internal data structure . not private as no protected option
  dynamic wrapped_json;

  /// better to use this getter outside
  get json => wrapped_json;

  set json(dynamic someJson) {
    wrapped_json = someJson;
  }

  /// for debug purpose
  static String lastInvocation;

  /// Constructor  via a factory returns the right map or list version
  /// jsonInput can be
  ///   nothing : create a map
  ///   a string to be  decoded by json
  ///   an already typed json or equivalent : create a map or a list
  /// initial is to retype the map & list in dynamic at first construct
  /// and to avoid to redo that in recursive construction.

  factory MapList([dynamic jsonInput]) {
    // if empty, create a simple Map<dynamic, dynamic>
    if (jsonInput == null) {
      return MapListMap.json({});
    }
    // try to decode a string and normalise structure
    if (jsonInput is String) {
      var result = trappedJsonDecode(jsonInput);
      if (result == null) return null;
      if (result is Map) return (MapListMap.json(result));
      if (result is List) return (MapListList.json(result));
      return MapList.json(result);
    }

    if (jsonInput is List) return MapListList.json(jsonInput);
    if (jsonInput is Map) return MapListMap.json(jsonInput);
    log.warning(
        '** a MapList must be json compatible, not a ${jsonInput.runtimeType}. null returned');
    return null;
  }

  /// real common constructor behind the factory
  /// we enforce json dynamic types to avoid later error
  MapList.json(dynamic jsonInput) {
    json = jsonInput;
    //json = convert.json.decode(convert.json.encode(jsonInput));
  }

  /// common methods for map ad list in front of the json data
  get isEmpty => json.isEmpty;

  get isNotEmpty => json.isNotEmpty;

  clear() => json.clear();

  remove(var someEntry);

  // overriden by MapListMap only
  bool containsKey(String aKey) {
    return false;
  }



  // notice early if we are on set or a get
  bool setter;

  // for more explicit warning
  String originalScript;

  // mut remember last rank used while walking
  int lastRank;

  // must remember last entry in a map
  var lastNameOfKeyInMap;

  // what is to set in interpreter
  dynamic dataToSet;

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
  /// see later that exec reuses this internal mechanism to share code.

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var member = invocation.memberName;
    String name;
    if (member is Symbol) {
      name = MirrorSystem.getName(member);

      // ------------------ getters if no equals sign
      if (name.endsWith('=') == false) {
        // detect function calls that have arguments
        var next;
        if (invocation.positionalArguments.length > 0) {
          return checkFunctionCall(invocation);
        }

        /// getter returns another MapList to continue or a data at the end
        /// but if it is a list, error as we expect a [ ]
        if (this is MapListList) {
          if (name == 'last') {
            next = wrapped_json[wrapped_json.length - 1];
          } else {
            log.warning(
                '** Naming error: trying to get a key "$name" in a List. null returned ');
            return null;
          }
        } else // not a List advance in map
        {
          lastInvocation = name;
          next = wrapped_json[name];
        }
        if ((next is Map) || (next is List)) {
          return MapList(next); //,false
        } else
          return next; //wrapped_json[name];
      }
      /*
      else this is a setter
      */
      else
      // setters with equal sign
      {
        name = name.replaceAll("=", "");

        dynamic param = invocation.positionalArguments[0];

        // special case : '.last = '
        if (name == 'last') {
          if (this is MapListList) {
            wrapped_json[wrapped_json.length - 1] = param;
            return true;
          } else {
            log.warning(
                '** calling .last is allowed only on a List $lastInvocation');
          }
        }

        wrapped_json[name] = param;
        return true;
      }
    } else {
      log.warning('illegal symbol in a method call : $member');
    }
  }

  /// at these days no specific method call are allowed
  dynamic checkFunctionCall(Invocation invocation) {
    log.severe(
        '** ${invocation.memberName} ${invocation.positionalArguments[0]} is invalid. No action done **');
    return false;
  }

  /// ----------------------- Interpreter ----------------------
  /// Some regex to help
  /// scalp : group 1 : all terms like root.show[1].etc splitted by .
  /// group2 : function signature someFunc( some parameter)
  static final reg_scalp_relax = RegExp(
      //r"""(add\s?\(.*\)|addAll\s?\(.*\)|[\w\d_ \?\s\[\]{}:,"']*)[\.=]""");
      r"""(|[\w\d_ \?\s\[\]{}:,"']*)[\.=\s]|(.*\(.*\))""");

  /// detect (several) index [123] ["abc"]
  static final reg_brackets_relax = RegExp(r"""\[["']?[A-Za-z0-9]*["']?]\??""");

  // extract from ["abcAZA"] or ['abcAZA'] or [  "abcAZA" ] etc.
  static final reg_indexString =
      RegExp(r"""\[\s*['"]?([a-zA-Z0-9\s]*)['"]?\]""");

  /// extract num index [123] group(1) and [last] group(2) . space allowed @todo remove [last] will be .last
  static final reg_index_List =
      RegExp(r"""\[\s*?([(0-9]*\s*?)\]|\[\s?(last)\s?\]""");

  /// clean before searching = sign
  static final RegExp reg_clean_out_assignment =
      RegExp(r"""[\("'{].*[\('"\)}]""");

  /// isolate var name person[12] or name.  -> person
  static final reg_dry_name = RegExp(r"""^"?([A-Za-z_][A-Za-z_0-9]*)"?""");

  /// identify json candidates : begin and end by [ ] or { }
  static final reg_mapList = RegExp("^[\\[\\{].*[\\}\\]]");

  /// trap .add method in a part
  static final reg_check_add = RegExp(r"""^add\((.*)\)""");

  /// trap .add or .addAll in a raw script
  ///
  static final reg_check_add_addAll = RegExp(r"""(.add\(.*\)|.addAll\(.*\))""");

  /// trap .addAll method in a script
  static final reg_check_addAll = RegExp(r"""^addAll\((.*)\)""");

  /// find remove with parameter
  static final reg_check_remove = RegExp(r"""^remove\s*?\((.*)\)""");

  /// find clear  with no parameter
  static final reg_check_clear = RegExp(r"""^clear\s*?\((\s*)\)""");

  /// trap equal sign = out of quotes
  /// returns [lhs,rhs]
  List split_lhs_rhs(String aScript) {
    String lhs, rhs;

    // first clean function parameters between ()
    var aScriptCleaned = (aScript.replaceAll(reg_clean_out_assignment, ""));
    // search =
    var equalsPos = aScriptCleaned.indexOf('=');
    if (equalsPos != -1) {
      lhs = aScript.substring(0, equalsPos);
      // rhs without = sign
      rhs = aScript.substring(equalsPos + 1);
    } else {
      rhs = null;
      lhs = aScript;
    }
    // print('PLA-lhs: $lhs   rhs: $rhs');
    return [lhs, rhs];
  }

  /// exec demands arrives here in one big string
  /// A front part is isolated and code walk through to find position
  /// Once found, depending of an equal sign, returns a data or set a data
  ///
  /// Empty exec script will return current position
  /// solo index '[1]' will return the [1] of current (if list)
  ///
  dynamic exec([String aScript = ""]) {
    // if a call with empty parenthesis
    if (aScript == null) aScript = '';
    aScript = aScript.trim();
    originalScript = aScript;
    /*
     split into parts ending by . or =
     if no = can leave a last name like boof.price
     soo we add it a dot : boof.price. to facilitate split
     */
    var result = split_lhs_rhs(aScript);
    // prepare rhs data and indicate a setter with data
    setter = false;
    String rawDataToSet = result[1];
    if (rawDataToSet != null) {
      print('setter : ${result[0]}  set to ${result[1]} ');
      setter = true;
      dataToSet = adjustParam(rawDataToSet.trim());
    }
    // now evaluate left hand side
    dynamic node = jsonNode(wrapped_json, result[0].trim()).nodesAndEdge;

    print(' au retour $node ${node is List} ${node is Map}');
    if (! setter) {
      if (node.currentNode == null) return null;
      if (node.currentNode is List) return MapListList.json(node.currentNode); //----> exit
      if (node.currentNode is Map) return MapListMap.json(node.currentNode); //----> exit
      return node.currentNode;
    }
    /*
     setter
     is there some function call in the last edge ?
     */
    node.previousNode[node.advanceEdge] = dataToSet;
    return true;
  }

  /*dynamic specialWords(String command) {
    print('PLA381 special word $command');
    if (command == "isEmpty") return previous.isEmpty; //--> exit
    if (command == "isNotEmpty") return previous.isNotEmpty; //--> exit
    // for length and last, must check get or set
    if (setter == false) {
      if (command == "length") return previous.length;
      // must check List
      if (command == "last") return previous.last;
    }
    // we are on setters
    if (command == "length") {
      previous.length = dataToSet;
      return true;
    }
    if (command == "last") {
      previous.last = dataToSet;
      return true;
    }

    return "pouet";
  }
*/
/*
  ///
  /// advance on index from the current point where.
  /// return false if something wrong, else had advance on where
  /// loop on everal [][] if any
  ///

  bool applyIndex(String aPathStep) {
    var bracketsList = reg_brackets_relax.allMatches(aPathStep);
    for (var aBl in bracketsList) {
      var anIndex = aBl.group(0);
      bool nullable = anIndex.endsWith('?');
      //----------- apply a numerical index on a List
      // extract num index [123] group(1)  . space allowed
      var numIndex = reg_index_List.firstMatch(anIndex);

      //--- [ 123 ] only on a List ----------
      if (numIndex != null) {
        print('PLA374 ${numIndex.group(1)}');
        var index = numIndex.group(1);
        if ((where is List) == false) {
          log.warning(
              '** originalScript: $anIndex must be applied to a List. ${exitMessage(setter)} ');
          return false;
        }
        var rank;
        lastRank = null;
        // a numeric index
        if (index != null) {
          rank = num.tryParse(index);
          if (rank == null) {
            log.warning(
                '** wrong index on a list :$originalScript. ${exitMessage(setter)}');
            return false;
          }
        }
        // index is a valid int check range
        if ((rank < 0) || (rank >= where.length)) {
          if (!nullable) // no error if anticipated
            log.warning(
                '** $originalScript not found by interpreter . ${exitMessage(setter)}  ');
          log.warning(
              '** Index $rank out of range   0.. ${where.length} in $originalScript');
          return false;
        }
        // this is a List, Index is valis advance at this rank
        // advance
        previous = where;
        where = where[rank];
        lastRank = rank;
        // as we have found en entry, we no more rely on the map
        lastNameOfKeyInMap = null;
        continue; // could be others index including standard notation on map
      } // numeric  index

      //----------- apply a textual index on a map
      // this is for the old style access map["abc"]["def"]
      var stringIndex = reg_indexString.firstMatch(anIndex);
      if (stringIndex != null) {
        var nameOfIndex = stringIndex.group(1);
        if ((where is Map) == false) {
          {
            log.warning(
                '** $originalScript: index $anIndex must be applied to a map. ${exitMessage(setter)}  ');
            return false;
          }
        }
        var next = where[nameOfIndex];
        // not found. Stop here leave details to caller
        if (next == null) return true;
        // found, continue loop on [ ]
        previous = where;
        where = next;
        continue;
      }
    } //for brackets
    // everything ok for that part
    return true;
  }
*/

  ///
  /// when using script, data in string has to become real values
  /// A string between quotes becomes a cleaned string
  /// string true/false becomes booleans
  /// string null becomes null
  /// any string (without quotes) are tested to be a valid number
  /// a string eligible to be a json-like structure is decoded
  /// if the json is not valid, returns a null and log a warning error
  ///
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
      var result = trappedJsonDecode(found.group(0));

      return result;
    }
    // nothing special returns original
    return param;
  }

  ///
  /// when found in script some func( ) , execute here
  dynamic execFunction(dynamic where, dynamic aFunction,
      [String aScript = ""]) {
    // ----- function add(something) usable on List onl
    print('PLA0: $aFunction');
    var foundAdd = reg_check_add.firstMatch(aFunction);
    if (!(foundAdd == null)) {
      dynamic dataToSet = foundAdd.group(1);
      dataToSet = adjustParam(dataToSet);
      if (where is List)
        where.add(dataToSet);
      else {
        stderr.write(
            '** $aFunction:  method add is not valid outside a List . data not added\n');
      }
      return null;
    }

    // ----  function addAll usable on List and Map
    var foundAddAll = reg_check_addAll.firstMatch(aFunction);

    if (!(foundAddAll == null)) {
      dynamic dataToSet = foundAddAll.group(1);
      dataToSet = adjustParam(dataToSet);
      print('PLA543 $dataToSet $where ${where is Map} ${dataToSet is Map}');
      // due to rigid type checking in standard addAll, use a loop on elements
      if (where is List && dataToSet is List) {
        dataToSet.forEach((value) {
          where.add(value);
        });
        return where;
      }
      if (where is Map && dataToSet is Map) {
        dataToSet.forEach((key, value) {
          where[key] = value;
        });
        print('PLA555 $where');
        return where;
      }
      log.warning(
          'try to addAll non compatible data : $aScript Allowed : map.addlAll(map); list.addAll(list);');
      return null;
    }
    //----- function remove(something)
    var foundRemove = reg_check_remove.firstMatch(aFunction);
    if (foundRemove != null) {
      dynamic dataToRemove = foundRemove.group(1);
      dataToRemove = adjustParam(dataToRemove);
      return where.remove(dataToRemove);
    }
    var foundClear = reg_check_clear.firstMatch(aFunction);
    if ((foundClear != null)) {
      where.clear();
      return true;
    }

    log.warning('** unknown function : $aFunction . No action done ');
    return false;
  }

  ///
  ///
  static dynamic normaliseByJson(dynamic something) {
    // can assign or add a Maplist
    if (something is MapList)
      return something.wrapped_json; //something = something.wrapped_json;
    if ((something is List) || (something is Map)) return something;
    return something;
  }

  /// choose to return null rather to crash
  static trappedJsonDecode(String something) {
    try {
      return convert.json.decode(something);
    } catch (e) {
      log.warning('** wrong json data. null returned . \n Original error: $e ');
      return null;
    }
  }

  String exitMessage(bool setter) {
    if (setter == null) return 'null returned';
    return 'no action done ';
  }

  @override
  String toString() {
    return json.toString();
  }

  String beginningOf(var someInfo, [int len = 80]) {
    if (someInfo.toString().length < len) len = someInfo.toString().length;
    return someInfo.toString().substring(0, len);
  }
}
