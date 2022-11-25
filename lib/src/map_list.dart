import 'dart:convert' as convert;
import 'package:map_list_dot/map_list_dot.dart';

/// MapList storage is a simple Wrapper on any structure made of
/// Lists, Maps and leaf Values of any type, as or like a json structure
/// MapList allows access by a dot notation in code and with script

class MapList {
  static final log = Logger('MapList');

  /// internal data structure . not private as no protected option
  dynamic wrapped_json;

  /// better to use this getter outside
  dynamic get json => wrapped_json;

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
    if (jsonInput is String)
      json = convert.json.decode(convert.json.encode(jsonInput));
    json = jsonInput;
  }

  /// common methods for map ad list in front of the json data
  bool get isEmpty => json.isEmpty;

  bool get isNotEmpty => json.isNotEmpty;

  void clear() => json.clear();

  void remove(var someEntry);

  // overriden by MapListMap only
  bool containsKey(String aKey) {
    return false;
  }

  /// as we want to use the dot notation in code, we need a dynamic
  dynamic get me => this;
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

  /// decouple from mirrors to keep the name from toString
  /// symbol("name")
  String getSymbolName(Symbol symbol) {
    return (symbol.toString().split('"')[1]);
  }

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
  /// see later that eval reuses this internal mechanism to share code.

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var member = invocation.memberName;
    String name;
    if (member is Symbol) {
      name = getSymbolName(member);
      // ------------------ getters if no equals sign
      if (name.endsWith('=') == false) {
        // detect function calls that have arguments
        var next;
        if (invocation.positionalArguments.isNotEmpty) {
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
        } else {
          return next;
        } //wrapped_json[name];
      }
      /*
      else this is a setter
      */
      else
      // setters with equal sign
      {
        name = name.replaceAll('=', '');
        dynamic param = invocation.positionalArguments[0];

        // special case : '.last =  and .length = '
        if (this is MapListList) {
          if (name == 'last') {
            wrapped_json[wrapped_json.length - 1] = param;
            return true;
          }
          if (name == 'length') {
            wrapped_json.length = param;
            return true;
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

  /// clean before searching = sign
  static final RegExp reg_clean_out_assignment =
      RegExp(r'''(\{.*\})|(['"][\w=\s\[\]\d]*["'])''');

  /// identify json candidates : begin and end by [ ] or { }
  static final reg_mapList = RegExp('''^[\\[\\{].*[\\}\\]]''');

  /// at the end of a script could be a function
  static final reg_find_function = RegExp(r'''(.*\(.*\))''');

  /// trap .add method in a part
  static final reg_check_add = RegExp(r'''^add\s*?\((.*)\)''');

  /// trap .addAll method in a script
  static final reg_check_addAll = RegExp(r'''^addAll\s*?\((.*)\)''');

  /// find remove with parameter
  static final reg_check_remove = RegExp(r'''^remove\s*?\((.*)\)''');

  /// find clear  with no parameter
  static final reg_check_clear = RegExp(r'''^clear\s*?\((\s*)\)''');

  /// trap equal sign = out of quotes
  /// returns [lhs,rhs]
  List split_lhs_rhs(String aScript) {
    String lhs, rhs;
    // first clean = sign out of main script.
    var aScriptCleaned = (aScript.replaceAll(reg_clean_out_assignment, ''));
    // search = in the remaining
    var equalsPos = aScriptCleaned.indexOf('=');
    // no = it's a get
    if (equalsPos == -1) {
      rhs = null;
      lhs = aScript;
    } else
    // suppose that the remaining is the first = in script
    {
      var two = aScript.split('=');
      lhs = two[0];
      // rhs without = sign
      rhs = two[1];
    }
    return [lhs, rhs];
  }

  /// eval demands arrives here in one big string
  /// A front part is isolated and code walk through to find position
  /// Once found, depending of an equal sign, returns a data or set a data
  ///
  /// Empty eval script will return current position
  /// solo index '[1]' will return the [1] of current (if list)
  ///
  dynamic eval([String aScript = '']) {
    // if a call with empty parenthesis
    aScript ??= '';
    aScript = aScript.trim();

    originalScript = aScript;
    // some inLine '''xxx''' reformated by dart
    // can leave CR or LF harmful for regex
    aScript = aScript.replaceAll('\n', '');
    aScript = aScript.replaceAll('\r', '');
    /*
     split into parts ending by . or =
     if no = can leave a last name like boof.price
     soo we add it a dot : book.price. to facilitate split
     */
    var result = split_lhs_rhs(aScript);
    // prepare rhs data and indicate a setter with data
    setter = false;
    String rawDataToSet = result[1];
    if (rawDataToSet != null) {
      setter = true;
      dataToSet = adjustParam(rawDataToSet.trim());
    }
    // now evaluate left hand side
    var lhs = result[0].trim();
    dynamic node = JsonNode(wrapped_json, lhs, originalScript);
    // advanceEdge is the last part execute
    /*print(
        ' once back form json: $node  ${node.toNode is List} ${node.toNode is Map} ${node.edge is String} $setter');*/

    if ((node.edge == null) && (originalScript != '')) {
      log.warning('unable to use path  $originalScript. null returned');
      return null;
    }
    /*
     is there some function call in the last edge ?
     last edge could be an int if [1] at the end
     */
    if (node.edge is String) {
      var foundFunc = reg_find_function.firstMatch(node.edge);
      if (foundFunc != null) return execFunction(node);
    }
    // get something
    if (!setter) {
      if (node.toNode == null) {
        /*
        as unknown name is a map is allowed,
        malformed can arrive up to there as JsonNode.reg_dry_name
        to be enhanced with a best test upstream
         */
        var residu = node.edge;
        if (residu == 'addAll') {
          log.warning('malformed addAll in $originalScript');
        }
        if (residu == 'add') {
          log.warning('malformed add function in $originalScript');
        }
        if (residu == 'remove') {
          log.warning('malformed remove in $originalScript');
        }
        return null;
      } // could have malformed function
      if (node.toNode is List) {
        return MapListList.json(node.toNode);
      } //----> exit
      if (node.toNode is Map) return MapListMap.json(node.toNode); //----> exit
      return node.toNode;
    } else {
      // else standard assignment in a setter
      if ((node.fromNode is Map) || (node.fromNode is List)) {
        if (node.edge == 'length') return setLength(node);
        try {
          node.fromNode[node.edge] = dataToSet;
        } catch (e) {
          log.warning(
              'unable to assign $originalScript. Think about <String,dynamic> Maps and <dynamic> Lists. No action done.\n $e ');
          return false;
        }
        return true;
      } else {
        log.warning(
            ' try to apply [$originalScript] on a: ${node.fromNode.runtimeType} node. No action done');
        node.toNode = null;
        return false;
      }
    }
  }

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
    if (param == null) return null;
    // if between ' or between " extract and leaves as String
    if ((param[0] == '"') && param.endsWith('"')) {
      return param.substring(1, param.length - 1);
    }
    if ((param[0] == "'") && param.endsWith("'")) {
      return param.substring(1, param.length - 1);
    }
    if (param == 'true') return true;
    if (param == 'false') return false;

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
  /// A function is to apply at the lastNode
  ///
  dynamic execFunction(dynamic node) {
    var aFunction = node.edge;
    // ----- function add(something) usable on List onl
    var foundAddParam = reg_check_add.firstMatch(aFunction)?.group(1);
    if (foundAddParam != null) {
      dynamic dataToSet = adjustParam(foundAddParam);
      if (dataToSet == null) return false;
      if (node.toNode is List) {
        node.toNode.add(dataToSet);
        return true;
      } else {
        log.warning(
            '** $aFunction:  method add is not valid outside a List . data not added\n');
        return false;
      }
    } //add

    // ----  function addAll usable on List and Map
    var foundAddAllParam = reg_check_addAll.firstMatch(aFunction)?.group(1);
    if (foundAddAllParam != null) {
      dynamic dataToSet = adjustParam(foundAddAllParam);
      if (dataToSet == null) {
        return false;
      } else {
        // due to rigid type checking in standard addAll, use a loop on elements
        if ((node.toNode is List) && (dataToSet is List)) {
          dataToSet.forEach((value) {
            node.toNode.add(value);
          });
          return true;
        }
        if ((node.toNode is Map) && (dataToSet is Map)) {
          dataToSet.forEach((key, value) {
            node.toNode[key] = value;
          });
          return true;
        }
        /*
       type not compatible with map or list
       could be because dataToset is null due to wrong json for example
       ${node.edge} has the content.
   */
        log.warning(
            'trying to addAll(${dataToSet.runtimeType}) on  ${node.beginningOf(node.toNode, 20)} ');
        return null;
      }
    }
    //----- function remove(something)
    var foundRemoveParam = reg_check_remove.firstMatch(aFunction)?.group(1);
    if (foundRemoveParam != null) {
      dynamic dataToRemove = adjustParam(foundRemoveParam);
      return node.toNode.remove(dataToRemove);
    }
    // function clear has been done in json part

    log.warning('** unknown function : $aFunction . No action done ');
    return false;
  }

  /// special case with length =
  ///
  bool setLength(node) {
    if (node.fromNode is List) {
      node.fromNode.length = dataToSet;
      return true;
    } else {
      log.warning(
          'unable to change length on a Map: $originalScript . no action done ');
      return false;
    }
  }

  ///
  /// can happens with an inline structure or a MapList to add
  /// so return the json part to be added to the other json part
  static dynamic normaliseByJson(dynamic something) {
    // can assign or add a Maplist
    if (something is MapList) {
      return something.wrapped_json;
    }
    if ((something is List) || (something is Map)) {
      return something;
    }
    return something;
  }

  /// choose to return null rather to crash
  static dynamic trappedJsonDecode(String something) {
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
