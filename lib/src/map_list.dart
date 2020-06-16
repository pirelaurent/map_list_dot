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
      // ------------------ setters if equals
      if (name.endsWith('=') == false) {
        // function calls have arguments
        if (invocation.positionalArguments.length>0) {
          return checkFunctionCall(invocation);
        }

        /// getter returns another MapList to continue or a data at the end
        /// but if it is a list, error
        if (this is MapListList) {
          log.warning(
              '** Naming error: trying to get a key "$name" in a List. Null returned ');
          return null;
        }
        lastInvocation = name;
        var next = json[name];

        if ((next is Map) || (next is List)) {
          return MapList(next, false);
        } else
          return this.json[name];
      } /* else this is a setter */
    else
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
        wrapped_json[name] = param;
        return;
      }
    } else {
      log.warning ('illegal call : $member');
    }
  }

  /// at these days no specific method call are allowed
  dynamic checkFunctionCall(Invocation invocation){
    log.severe('** ${invocation.memberName} ${invocation.positionalArguments[0]} is invalid. No action done **');
    return false;
  }

  /// ----------------------- Interpreter ----------------------
  /// Some regex to help
  /// scalp : extract a front part of a script before a . or an equal
  static final reg_scalp_relax = RegExp(
      r"""(add\s?\(.*\)|addAll\s?\(.*\)|[\w\d_ \?\s\[\]{}:,"']*)[\.=]""");



  /// detect (several) index [123] ["abc"]
  static final reg_brackets_relax = RegExp(r"""\[["']?[A-Za-z0-9]*["']?]\??""");

  // extract from ["abcAZA"] or ['abcAZA'] or [  "abcAZA" ] etc.
  static final reg_indexString =
      RegExp(r"""\[\s*['"]?([a-zA-Z0-9\s]*)['"]?\]""");

  /// extract num index [123] group(1) and [last] group(2) . space allowed
  static final reg_index_List = RegExp(r"""\[\s*?([(0-9]*\s*?)\]|\[\s?(last)\s?\]""");

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
    // allow set word for add and addAll

    if (reg_check_add_addAll.firstMatch(aScript)?.group(2) != null) return true;
    return false;
  }

  /// interpreted execmust be something like set('lhs = rhs')
  /// due to habits, tolerate a set('lhs',rhs)
  /// which is transformed for interpreter in the right script
  ///
  /// to indicate a setter in exec a script. Check for an equals
  dynamic set([String aScript, dynamic optionalRhs]) {
    if (optionalRhs != null) {
      aScript = '$aScript = ${optionalRhs.toString()}';
    }
    if (foundEqualsSign(aScript)) {
      return (exec(aScript));
    } else {
      stderr.write(
          '** warning : calling set with no equal sign. Probably want a get : $aScript');
      return null;
    }
  }

  /// to indicate a getter in exec a script. Check no equals
  dynamic get([String aScript]) {
    if (aScript == null) return exec();
    if (!foundEqualsSign(aScript)) {
      return (exec(aScript));
    } else {
      stderr.write(
          '** warning : calling get with an equal sign. be sure it\'s not a set . null returned: $aScript');
      return null;
    }
  }

  /// exec demands arrives here in one big string
  /// A front part is isolated and executed to find next position
  /// execcall itself recursively for the following step
  /// On last step, depending of an equal sign, returns a data or set a data
  ///
  /// Empty execwill return current position
  /// solo index '[1]' will return the [1] of current (if list)
  ///
  dynamic exec([String aScript = ""]) {
    bool setter = false;
    aScript = aScript.trim();
    var originalScript = aScript;

    /*
     split into parts ending by . or =
     if no = can leave a last name like boof.price
     soo we add it a dot : boof.price. to facilitate split
     */
    Iterable rhs_s = reg_rhs.allMatches(aScript);
    var dataToSet;
    if (rhs_s.isNotEmpty) {
      // found an = evaluate rhs . it begins with '='
      String rawDataName = rhs_s.elementAt(0).group(0);
      var aDataName = rawDataName.substring(1).trim();
      dataToSet = adjustParam(aDataName);

      setter = true;
      // retract this part from script
      aScript = aScript.replaceAll(rawDataName, "").trim();
    }

    // add an ending point to facilitate split
    aScript += '.';
    // now the named variable one per one
    Iterable lhs_s = reg_scalp_relax.allMatches(aScript);

    /*
    the variable part can have enclosed index

     */
    dynamic where = this.json;
    dynamic previous = where;
    // to remember position once leaf reached
    var lastRank, lastNameOfIndex;
    var aVarName;

    for (var aLhs in lhs_s) {
      var aPathStep = aLhs.group(1);
      //remove the dot
      bool nullable = aPathStep.endsWith('?');
      // get name only (can be null if [ ] direct )

      // could be a reserved word
      var foundAdd = reg_check_add.firstMatch(aPathStep);
      if (!(foundAdd == null)) {
        dataToSet = foundAdd.group(1);
        dataToSet = adjustParam(dataToSet);

        if (where is List)
          where.add(dataToSet);
        else {
          stderr.write(
              '** $originalScript:  method add is not valid outside a List . data not added\n');
        }

        return null;
      }

      // could be a reserved word addAll
      var foundAddAll = reg_check_addAll.firstMatch(aPathStep);
      if (!(foundAddAll == null)) {
        dataToSet = foundAddAll.group(1);
        dataToSet = adjustParam(dataToSet);
        where.addAll(dataToSet);
        return null;
      }

/*
    not add or addAll, isolate dry name against any index [ ]
 */
      aVarName = reg_dry_name.firstMatch(aPathStep)?.group(1);

      /*
      try to find this var name. could be :
      simple : dico
      simple with nullable : dico?
      with brackets : scores[10]
      with nullable at several places : scores?[10]?
      with several brackets : name["what"].scores[10]
      starting at the very front : [12] ["pouet"]
      */

      if (nullable) aVarName = aVarName.substring(0, aVarName.length - 1);
      /*
       before attempting to apply some index, find the dry part
       */
      if (aVarName != null) {
        // we have a name : must exists an entry . Implies a map, except for length
        if (aVarName == "length") {
          if (where is List) return where.length;
          if (where is Map) {
            if (aPathStep == "length") return where.length;
            // otherwise will be some ["length"] asking for a key leave it
          }
        }
        // any key is valid only on a map
        if (!(where is Map)) {
          log.warning(
              "** $originalScript: searching '$aVarName' in a ${where.runtimeType} ");
          if (setter)return false; else return null;
        }
        // could be unknown but a creation
        previous = where;
        var next = where[aVarName];
        lastNameOfIndex = aVarName;
        lastRank = null;

        if (nullable && (next == null)) return null; // that's all
        if (next == null) {
          // if setter create en entry . will be overwrite by the equals
          if (setter) {
            previous[aVarName] = null;
            next = where[aVarName];
          } else {
            return null;
          }
        }

        previous = where;
        where = next;
      }

      /*
       we now progress on index
         accept ["abc"] ['abc'] on a map and [123] [last] on a list
       */
      var bracketsList = reg_brackets_relax.allMatches(aPathStep);

      for (var aBl in bracketsList) {
        var anIndex = aBl.group(0);
        bool nullable = anIndex.endsWith('?');
        // extract num index [123] group(1) and [last] group(2) . space allowed
        var numIndex = reg_index_List.firstMatch(anIndex);
        //-------------------- [ 123 ] on List ----------
        if (numIndex != null) {
          if (!(where is List)) {
            log.warning(
                '** $originalScript: $anIndex must be applied to a List ');
            if (setter) return false; else return null;
          }
          var rawRank, rank;
          lastRank = null;
          // normal num index
          rawRank = numIndex.group(1);
          if(rawRank != null) rank = num.tryParse(rawRank);
          // keyword last
           else {
          rawRank = numIndex.group(2);
          if (rawRank!=null) rank = where.length-1;
               }
           // check range
          if ((rank < 0) || (rank >= where.length)) {
            if (!nullable) // no error if anticipated
              log.warning(
                  '** unexisting $originalScript in interpreter . null returned  ');
            if (setter) return false; else return null;
          }
          // advance
          previous = where;
          where = where[rank];
          lastRank = rank;
          lastNameOfIndex = null;
          continue;
        } // num index
        //----------------------["abc"] on Map -------------
        lastNameOfIndex = null;
        var stringIndex = reg_indexString.firstMatch(anIndex);
        if (stringIndex != null) {
          var nameOfIndex = stringIndex.group(1);
          if (!(where is Map)) {
             {
              log.warning(
                  '** $originalScript: index $anIndex must be applied to a map.  ');
              if (setter) return false; else return null;
            }
          }
          var next = where[nameOfIndex];
          if (next == null) {
            // unknown key in map creates the entry in anticipation of an =
            if (setter) {
              where[nameOfIndex] = Map<String, dynamic>();
              where = where[nameOfIndex];
              lastNameOfIndex = nameOfIndex;
            } else {
              log.warning(
                  '** $originalScript: warning $nameOfIndex in $anIndex not found. ');
              if (setter) return false; else return null;
            }
          }
          previous = where;
          where = next;
          continue;
        }
      } //for brackets

/*
 when we arrive here, all index have been applied to the dry variable
 but if it is not the last part, let's loop
 check if a set or get
 */
    } // for lhs

    if (setter) {
      if (previous is List) {
        if (lastRank != null)
          previous[lastRank] = dataToSet;
        else
          previous = dataToSet;
        return true;
      }

      if (previous is Map) {
        if (lastNameOfIndex != null)
          previous[lastNameOfIndex] = dataToSet;
        else
          previous = dataToSet;
        return true;
      }
      // we have reached a leaf
      where = dataToSet;
      return true;
    } else // getter
    {
      if (where is List) return MapListList.json(where);
      if (where is Map) return MapListMap.json(where);
      return where;
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

  /*
    .add or .addAll method directly on json data
  */
  bool foundAdd(var aScript) {
    var foundTermAdd = reg_check_add.firstMatch(aScript);
    if (foundTermAdd == null) return false;
    // add is significant for List when script
    dynamic thingToAdd;
    if ((this is MapListList) || (this is MapListMap)) {
      // what is the something part
      thingToAdd = foundTermAdd.group(0);
      // remove "add(   )" parts
      thingToAdd = thingToAdd.substring(4, thingToAdd.length - 1);
      thingToAdd = adjustParam(thingToAdd);
      if (this is MapListList) {
        MapListList m = this;
        m.add(thingToAdd);
      }
      if (this is MapListMap) {
        MapListMap m = this;
        m.addAll(thingToAdd);
      }
    } else {
      log.warning("** trying to use add $thingToAdd out of a List ");
      return false;
    }
    return true;
  }

  /*
       if (.addAll(same for .addAll
  */
  bool foundAddAll(aScript) {
    var foundTermAddAll = reg_check_addAll.firstMatch(aScript);
    if (foundTermAddAll == null) return false;
    dynamic thingToAdd;
    if ((this is MapListList) || (this is MapListMap)) {
      // what is the something part
      thingToAdd = foundTermAddAll.group(0);
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
    } else {
      log.warning("** trying to use addAll $thingToAdd out of a Map or a List ");
      return false;
    }
    return true;
  }


  /// the most simple and sure method to align the types
  /// Not so efficient? but used only one time on setter
  ///
  static dynamic normaliseByJson(var something) {
    if (something is MapList) something = something.wrapped_json;

    var prepare = convert.json.encode(something);

    var resu = trappedJsonDecode(prepare);
    return resu;
  }

  /// choose to return null rather to crash
  static trappedJsonDecode(String something) {
    try {
      return convert.json.decode(something);
    } catch (e) {
       log.warning ('** wrong data. MapList will return null . \n Original error: $e ');
      return null;
    }
  }

  @override
  String toString() {
    return json.toString();
  }
}
