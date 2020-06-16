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

  factory MapList([dynamic jsonInput, bool initial = true]) {
    // if empty, create a simple Map<dynamic, dynamic>
    if (jsonInput == null) jsonInput = {};
    // try to decode a string and normalise structure
    if (jsonInput is String)
      jsonInput = trappedJsonDecode(jsonInput);
    else {
      if (initial) jsonInput = normaliseByJson(jsonInput);
    }

    if (jsonInput is List) return MapListList.json(jsonInput);
    if (jsonInput is Map) return MapListMap.json(jsonInput);
    return null;
    // if empty, create a simple Map<dynamic, dynamic>
    //return MapListMap.json(normaliseByJson({}));
  }

  /// real common constructor behind the factory
  MapList.json(dynamic jsonInput) {
    json = jsonInput;
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
                '** Naming error: trying to get a key "$name" in a List. Null returned ');
            return null;
          }
        } else // not a List advance in map
        {
          lastInvocation = name;
          next = wrapped_json[name];
        }
        if ((next is Map) || (next is List)) {
          return MapList(next, false);
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
        /*
           if coming by code, param is generally a constructed thing
           but string is allowed like in interpreter.
           in both cases something to do before insertion
         */
        param = normaliseByJson(param);
        if (param is String) param = adjustParam(param);
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

  /// extract num index [123] group(1) and [last] group(2) . space allowed
  static final reg_index_List =
      RegExp(r"""\[\s*?([(0-9]*\s*?)\]|\[\s?(last)\s?\]""");

  // get part after = if exists
  static final reg_rhs = RegExp(r"""=.*""");

  /// isolate var name person[12] or name.  -> person
  static final reg_dry_name = RegExp(r"""(^[A-Za-z_][A-Za-z_0-9]*)""");

  /// identify json execcandidates : begin and end by [ ] or { }
  static final reg_mapList = RegExp("^[\\[\\{].*[\\}\\]]");

  /// trap .add method in a part
  static final reg_check_add = RegExp(r"""^add\((.*)\)""");

  /// trap .add or .addAll in a raw script
  ///
  static final reg_check_add_addAll =
      RegExp(r"""(["'][\w\s=]*["'])|((add|addAll)\((.*)\))""");

  /// trap .addAll method in a script
  static final reg_check_addAll = RegExp(r"""^addAll\((.*)\)""");

  /// find remove with parameter
  static final reg_check_remove = RegExp(r"""^remove\s*?\((.*)\)""");

  /// find remove with parameter
  static final reg_check_clear = RegExp(r"""^clear\s*?\((\s*)\)""");

  /// trap equal sign = out of quotes
  static final reg_equals_outside_quotes =
      RegExp(r"""(["'][\w\s=]*["'])|(=)""");

  /*
 with this regex,
 A match:
 group(1) : anything in quote
 group(2) : equal sign, out of quotes

 */
  static bool foundEqualsSign(String aScript) {
    var itEquals = MapList.reg_equals_outside_quotes.allMatches(aScript);
    if (itEquals == null) return false;
    for (var x in itEquals) {
      if (x.group(2) == '=') {
        return true;
      }
    }
    // allow setter for add and addAll

    if (reg_check_add_addAll.firstMatch(aScript)?.group(2) != null) return true;
    return false;
  }

  /// interpreted exec must be something like set('lhs = rhs')
  /// due to habits, tolerate a set('lhs',rhs)
  /// which is transformed for interpreter in the right script
  ///
  /// to indicate a setter in exec a script. Check for an equals
  dynamic set(String aScript) {
    return (exec(aScript, 'set'));
  }

  /// to indicate a getter in exec a script. Check no equals
  dynamic get([String aScript]) {
    return (exec(aScript, 'get'));
  }

  /// exec demands arrives here in one big string
  /// A front part is isolated and executed to find next position
  /// execcall itself recursively for the following step
  /// On last step, depending of an equal sign, returns a data or set a data
  ///
  /// Empty execwill return current position
  /// solo index '[1]' will return the [1] of current (if list)
  ///
  dynamic exec([String aScript = "", String getOrSet]) {
    bool setter = false;
    // if a call with empty parenthesis
    if (aScript == null) aScript = '';
    aScript = aScript.trim();
    var originalScript = aScript;
    var dataToSet;
    var exitMessageOnWarning='';

    /*
     split into parts ending by . or =
     if no = can leave a last name like boof.price
     soo we add it a dot : boof.price. to facilitate split
     */
    Iterable rhs_s = reg_rhs.allMatches(aScript);
    exitMessageOnWarning = ' -> null returned';
    if (rhs_s.isNotEmpty) {
      // found an = evaluate rhs . it begins with '='
      String rawDataName = rhs_s.elementAt(0).group(0);
      var aDataName = rawDataName.substring(1).trim();
      dataToSet = adjustParam(aDataName);
      // remember we are in a set with an equal

      setter = true;
      exitMessageOnWarning = 'no action done. -> false returned';

      // retract this part from script
      aScript = aScript.replaceAll(rawDataName, "").trim();
    }

    // add an ending point to facilitate detection of isolated word
    aScript += '.';
    // now the named variable one per one
    Iterable lhs_s = reg_scalp_relax.allMatches(aScript);

    /*
    the variable part can have enclosed index

     */
    dynamic where, previous, next;
    where = this.json;
    // when progressing must remember previous
    // as a get returns current value but a set affects the owner
    previous = where;
    // to remember position once leaf reached
    var lastRank, lastNameOfKeyInMap;
    var aDryName;

    // help to use the right term
    if (setter && (getOrSet != 'set')) {
      log.warning(
          '** warning : calling get with an equal sign. Be sure it\'s not a set . null returned: $aScript');
      return null;
    }
    if (!setter && (getOrSet == 'set')) {
      log.warning(
          '** warning : $aScript Calling set without = .Be sure it\'s not a get or an exec .no action done');
      return false;
    }

    /*------ will progress part1.part2.part3[ ]. etc
    can found at the end a function like remove(), clear() ..

     */
    for (var aLhs in lhs_s) {
      var aFunction = aLhs.group(2);
      // if a function allows exec, get or set
      if (aFunction != null) return execFunction(where, aFunction); //--> exit
      // get the part
      var aPathStep = aLhs.group(1);

      // get part name only without brackets (can be null if [ ] direct )
      aDryName = reg_dry_name.firstMatch(aPathStep)?.group(1);
      bool nullable = false;
      if (aDryName != null) {
        //check nullable . checked only at the end of the name part?[1]
        // no matter as returns null without crash at any step in a List.
        nullable = aDryName.endsWith('?');
        if (nullable) aDryName = aDryName.substring(0, aDryName.length - 1);
      }

      /*
      try to find this dry name in data .
      Next step will apply the [ ] [ ] on the found entry
      */
      if (aDryName != null) {
        // some name are special properties
        if (aDryName == "length") {
          if (where is List) return where.length;
          if (where is Map) {
            if (aPathStep == "length") return where.length;
            // otherwise will be some ["length"] asking for a key leave it
          }
        } //--> exit
        if (aDryName == "isEmpty") return where.isEmpty; //--> exit
        if (aDryName == "isNotEmpty") return where.isNotEmpty; //--> exit

        // any other key is valid only on a map except the word 'last'
        if ((!(where is Map)) && (aDryName != "last")) {
          log.warning(
              "**  cannot search a key ($originalScript) in a ${where.runtimeType}. $exitMessageOnWarning ");
          return (setter ? false : null);
        }

        if (aDryName == 'last') {
          previous = where;
          var rank = where.length - 1;
          next = where[rank];
          where = next;
          lastRank = rank;
          lastNameOfKeyInMap = null;
          continue;
        }
        // could be unknown but a creation

        previous = where;
        next = where[aDryName];
        lastNameOfKeyInMap = aDryName;
        lastRank = null;

        if (nullable && (next == null)) return null; //--> exit
        if (next == null) {
          // if setter create en entry . will be overwrite by the equals
          if (setter) {
            previous[aDryName] = null;
            next = where[aDryName];
          } else {
            return null;
          }
        }

        previous = where;
        where = next;
      }

      /*
       if dryName was null we are still at the root,
       otherwise en new place has been set in where
       we now progress on index
         accept ["abc"] ['abc'] on a map and [123] on a list
       */
      var bracketsList = reg_brackets_relax.allMatches(aPathStep);

      for (var aBl in bracketsList) {
        var anIndex = aBl.group(0);

        bool nullable = anIndex.endsWith('?');
        // extract num index [123] group(1)  . space allowed
        var numIndex = reg_index_List.firstMatch(anIndex);
        //-------------------- [ 123 ] on List ----------
        if (numIndex != null) {
          if (!(where is List)) {
            log.warning(
                '** $originalScript: $anIndex must be applied to a List. $exitMessageOnWarning ');
            return (setter ? false : null);
          }

          var rawRank, rank;
          lastRank = null;
          // normal num index
          rawRank = numIndex.group(1);
          if (rawRank != null) {
            rank = num.tryParse(rawRank);
          } else {
            log.warning('** wrong index on a list :$originalScript. $exitMessageOnWarning');
            return (setter ? false : null);
          }

          // check range
          if ((rank < 0) || (rank >= where.length)) {
            if (!nullable) // no error if anticipated
              log.warning(
                  '** $originalScript not found by interpreter . $exitMessageOnWarning  ');
            return (setter ? false : null);
          }

          // advance
          previous = where;
          where = where[rank];
          lastRank = rank;
          lastNameOfKeyInMap = null;
          continue;
        } // num index
        //----------------------["abc"] on Map -------------
        lastNameOfKeyInMap = null;
        var stringIndex = reg_indexString.firstMatch(anIndex);
        if (stringIndex != null) {
          var nameOfIndex = stringIndex.group(1);
          if (!(where is Map)) {
            {
              log.warning(
                  '** $originalScript: index $anIndex must be applied to a map. $exitMessageOnWarning  ');
              return (setter ? false : null); //----> exit
            }
          }
          var next = where[nameOfIndex];
          if (next == null) {
            // unknown key in map creates the entry in anticipation of an =
            if (setter) {
              where[nameOfIndex] = Map<String, dynamic>();
              where = where[nameOfIndex];
              lastNameOfKeyInMap = nameOfIndex;
            } else {
              log.warning(
                  '** $originalScript: warning $nameOfIndex in $anIndex not found. $exitMessageOnWarning ');
              return (setter ? false : null); //----> exit
            }
          }
          // advance a step
          previous = where;
          where = next;
          continue;
        }
      } //for brackets

/*
 when we arrive here, all optional index have been applied to the dry variable
 where is the last leaf , previous is it's owner
 A get returns the leaf while a set change its value using the owner
 */
    } // end loop for lhs

    // getter
    if (!setter) {
      if (where is List) return MapListList.json(where); //----> exit
      if (where is Map) return MapListMap.json(where); //----> exit
      return where; //----> exit
    }
    // setter
    // could be the list to set or an element in the list
    if (previous is List) {
      if (lastRank != null)
        previous[lastRank] = dataToSet;
      else
        previous = dataToSet;
      return true;
    }

    if (previous is Map) {
      if (lastNameOfKeyInMap != null)
        previous[lastNameOfKeyInMap] = dataToSet;
      else
        previous = dataToSet;
      return true;
    }
    log.warning('** try to set a value $dataToSet on a ${where.runtimeType}. $exitMessageOnWarning');
    return false;
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
    // nothing special returns original
    return param;
  }
  ///
  /// when found in script soome func( ) , execute here
  dynamic execFunction(dynamic where, dynamic aFunction) {
// could be a reserved word add
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

    // could be a reserved word addAll
    var foundAddAll = reg_check_addAll.firstMatch(aFunction);
    if (!(foundAddAll == null)) {
      dynamic dataToSet = foundAddAll.group(1);
      dataToSet = adjustParam(dataToSet);
      where.addAll(dataToSet);
      return null;
    }

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

  /// the most simple and sure method to align the types
  /// Not so efficient? but used only one time on setter
  ///
  static dynamic normaliseByJson(var something) {
    if (something is MapList) something = something.wrapped_json;

    var prepare = convert.json.encode(something);

    var result = trappedJsonDecode(prepare);
    return result;
  }

  /// choose to return null rather to crash
  static trappedJsonDecode(String something) {
    try {
      return convert.json.decode(something);
    } catch (e) {
      log.warning(
          '** wrong data. MapList will return null . \n Original error: $e ');
      return null;
    }
  }

  @override
  String toString() {
    return json.toString();
  }
}
