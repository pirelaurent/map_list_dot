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
    if (jsonInput == null) jsonInput = {};
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
        */
        // not a [ ] index
        wrapped_json[name] = param;
        return;
      }
    }
  }

  /// Some regex to help
  /// \ is useful for some regex (doubled avoid to be trapped by dart)
  /// scalp : extract a front part of a script

  // to allow trap of [toto]
  static final reg_scalp_relax = RegExp(
      r"""(add\s?\(.*\)|addAll\s?\(.*\)|[\w\d_ \?\s\[\]{}:,"']*)[\.=]""");

  /// detect num index [123]
  static final reg_brackets = RegExp("\\[[0-9]*\\]");

  /// detect (several) index [123] ["abc"]
  static final reg_brackets_relax = RegExp(r"""\["?[A-Za-z0-9]*"?]\??""");

  // extract from ["abcAZA"] or ['abcAZA'] or [  "abcAZA" ] etc.
  static final reg_indexString = RegExp(r"""\[\s*['"]([a-zA-Z0-9\s]*)['"]\]""");

  // extract form [123] or [  123  ]
  static final reg_indexNum = RegExp(r"""\[\s*([(0-9\s]*)\]""");

  // get part after = if exists
  static final reg_rhs = RegExp(r"""=.*""");

  /// isolate var name person[12] or name.  -> person
  static final reg_dry_name = RegExp(r"""(^[A-Za-z_][A-Za-z_]*)""");

  /// identify json script candidates : begin and end by [ ] or { }
  static final reg_mapList = RegExp("^[\\[\\{].*[\\}\\]]");

  /// trap .add method in a script
  static final reg_check_add = RegExp(r"""^add\((.*)\)""");

  /// trap .addAll method in a script
  static final reg_check_addAll = RegExp(r"""^addAll\((.*)\)""");

  /// script demands arrives here in one big string
  /// A front part is isolated and executed to find next position
  /// script call itself recursively for the following step
  /// On last step, depending of an equal sign, returns a data or set a data
  ///
  /// Empty script will return current position
  /// solo index '[1]' will return the [1] of current (if list)
  ///
  dynamic script([String aScript = ""]) {
    print(
        'PLA90:_______________________ at script $aScript on ${this.wrapped_json}');
    bool setter = false;
    aScript = aScript.trim();
    var originalScript = aScript;
    print('PLA91: $aScript');

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
      print("PLA92 : setter found: $dataToSet ${dataToSet.runtimeType}");
      setter = true;
      // retract this part from script
      aScript = aScript.replaceAll(rawDataName, "").trim();
    }

    // add an ending point to facilitate split
    aScript += '.';
    // now the named variable one per one
    Iterable lhs_s = reg_scalp_relax.allMatches(aScript);
    print('PLA..................................$aScript');
    for (var aLhs in lhs_s) {
      print(aLhs.group(1));
    }
    print('PLA..................................');
    /*
    the variable part can have enclosed index

     */
    dynamic where = this.wrapped_json;
    dynamic previous = where;
    // to remember position once leaf reached
    var lastRank, lastNameOfIndex;
    var aVarName;

    print('PLA93: on part de $where');
    for (var aLhs in lhs_s) {
      var aPathStep = aLhs.group(1);
      //remove the dot
      bool nullable = aPathStep.endsWith('?');
      // get name only (can be null if [ ] direct )
      print('PLA 94 aPathStep=========== $aPathStep');

      // could be a reserved word
      var foundAdd = reg_check_add.firstMatch(aPathStep);
      if (!(foundAdd == null)) {
        dataToSet = foundAdd.group(1);
        dataToSet = adjustParam(dataToSet);
        print('PLA96 Add $dataToSet $where');
        if (where is List)
          where.add(dataToSet);
        else {
          stderr.write(
              '** method add is not valid outside a List . data dataToSet not set\n');
        }
        ;
        return null;
      }

      // could be a reserved word addAll
      var foundAddAll = reg_check_addAll.firstMatch(aPathStep);
      if (!(foundAddAll == null)) {
        dataToSet = foundAddAll.group(1);
        dataToSet = adjustParam(dataToSet);
        print('PLA96 Add $dataToSet');
        where.addAll(dataToSet);
        return null;
      }

/*
    not add or addAll, isolate dry name against any index [ ]
 */
      aVarName = reg_dry_name.firstMatch(aPathStep)?.group(1);
      print('PLA95: aVarName: $aVarName');

      /*
      try to find this var name. could be :
      simple : dico
      simple with nullable : dico?
      with brackets : scores[10]
      with nullable at several places : scores?[10]?
      with several brackets : name["what"].scores[10]
      starting at the very front : [12] ["pouet"]
      */

      print(
          "PLA97 dry variable name : $aVarName in  $aPathStep nullable: $nullable");
      if (nullable) aVarName = aVarName.substring(0, aVarName.length - 1);
      /*
       before attempting to apply some index, find the dry part
       */
      if (aVarName != null) {
        // we have a name : must exists an entry . Implies a map
        if (!(this.wrapped_json is Map)) {
          stderr.write("* searching $aVarName in a ${this.runtimeType}\n");
          return null;
        }
        print('PLA98: on a ${where.runtimeType} $where');
        // could be unknown but a creation
        previous = where;
        var next = where[aVarName];
        lastNameOfIndex = aVarName;
        print('PLA99 Next : $next $nullable)');
        if (nullable && (next == null)) return null; // that's all
        if (next == null) {
          print('PLA99_1 $next $previous');
          // if setter create en entry . will be overwrite by the equals
          if (setter) {
            previous[aVarName] = null;
            next = where[aVarName];

          } else {
            // special case : length
            if (aVarName == "length") return where.length; //

            stderr.write(
                '** try to use a non existing key : $aVarName in $originalScript \n');
            return null;
          }
        }
        print('PLA99_2 previous:$previous where:$where next: $next lastNameOfIndex: $lastNameOfIndex');
        previous = where;
        where = next;
      }
      print('PLA100: we are on $where to use brackets ');
      /*
       we now progress on index
       */
      var bracketsList = reg_brackets_relax.allMatches(aPathStep);

      for (var aBl in bracketsList) {
        var anIndex = aBl.group(0);
        bool nullable = anIndex.endsWith('?');

        /*
         accept ["abc"] ['abc'] on a map and [123] on a list
         */

        var numIndex = reg_indexNum.firstMatch(anIndex);
        lastRank = null;

        if (numIndex != null) {
          var rawRank = numIndex.group(1);
          if (!(where is List)) {
            stderr
                .write('** $anIndex must be applied to a List. null returned ');
            return null;
          }
          print('PLAXX: $rawRank ');
          var rank = num.tryParse(rawRank);
          if ((rank < 0) || (rank >= where.length)) {
            if (!nullable) // no error if anticipated
              stderr.write(
                  '** wrong index $anIndex. null returned '); //@todo mmore explicit
            return null;
          }
          // advance
          previous = where;
          where = where[rank];
          lastRank = rank;
          print('PLAX1 $where $lastRank');
          continue;
        } // num index

        lastNameOfIndex = null;
        var stringIndex = reg_indexString.firstMatch(anIndex);
        if (stringIndex != null) {
          var nameOfIndex = numIndex.group(1);
          if (!(where is Map)) {
            stderr
                .write('** $anIndex must be an entry in a map. null returned ');
            return null;
          }
          var next = where[nameOfIndex];
          if (next == null) {
            if (setter) {
              where[nameOfIndex] = Map<String, dynamic>();
              where = where[nameOfIndex];
              lastNameOfIndex = nameOfIndex;
            } else {
              // not found and not a setter
              return null;
            }
            previous = where;
            where = next;
            continue;
          }
          ;
        }
      } //for brackets
      print('PLA on sort du loop de brackets');
/*
 when we arrive here, all index have been applied to the dry variable
 but if it is not the last part, let's loop
 check if a set or get
 */
    } // for lhs

    if (setter) {
      print(
          'PLA_Setter *****  lastNameOfIndex $lastNameOfIndex lastRank $lastRank previous $previous, where $where toset: $dataToSet ');
      if (previous is List) {
        if (lastRank != null)
          previous[lastRank] = dataToSet;
        else
          previous = dataToSet;
        return;
      } ;
      if (previous is Map) {
        if (lastNameOfIndex != null)
          previous[lastNameOfIndex] = dataToSet;
        else
          previous = dataToSet;
        return;
      }
      // we have reached a leaf
      where = dataToSet;
      return;
      print('PLA999 : $aVarName $previous $where');
      previous = dataToSet;
    } else // getter
       {

      if(where is List) return MapListList.json(where);
      if(where is Map) return MapListMap.json(where);
      return where;
    }

    return 'poets are always the best';
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
        m.add(thingToAdd);
      }
    } else {
      stderr.write("** trying to use add $thingToAdd out of Map or List ");
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
      stderr.write("** trying to use addAll $thingToAdd out of Map or List ");
    }
    return true;
  }

  /// find an item by its string name 'name' or name[rank]
  /// uses the common code by invokink noSuchMethod on the MapList
  /// can generate an error if rank is not valid and no nullable option

  dynamic getItemWithOptionalRank(String item) {
    print('PLA6: $item in getItem...');
    dynamic where;
    var originalItem = item;
    int rank;
    bool withBrackets = false;
    var rawRank;

    Iterable foundAll = reg_brackets_relax.allMatches(item); //
    for (var ff in foundAll) {
      rawRank = ff.group(0); // at this step, get the last one only
      print('PLA7: $rawRank');
    } // à déplacer

    // calculate a rank if numerical
    if (foundAll.isNotEmpty) {
      withBrackets = true;
      //found sample :rawRank-> [1]
      // clean the item -> book
      item = item.replaceAll(rawRank, '');
      // remove brackets  : rawRank ->1
      rawRank = rawRank.substring(1, rawRank.length - 1);
      rank = num.tryParse(rawRank);
      print('PLA8: $rank');
    }
    /*
     in rare case where the root is a List,
     some calls can arrive empty or as pure index '[2]'
     in this case apply to current
     */
    if (item == "") {
      where = this;
    } else {
      print('PLA9:$item');
      // first try to get an access to the item
      Invocation invocation = Invocation.getter(Symbol(item));
      where = noSuchMethod(invocation);
    }
    print('PLA10:$where ${where.runtimeType}');
    if (where == null) return where;
    // found something correct : if a valid rank, apply it
    if (withBrackets) {
      if (rank != null) {
        if (where is MapListList) {
          print('PLA11: ${where[rank]}');
          return where[rank];
        }
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

  /// the most simple and sure method to align the types
  /// Not so efficient? but used only one time on setter
  ///
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
