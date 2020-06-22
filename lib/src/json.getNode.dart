import 'package:map_list_dot/map_list_dot.dart';

/// interpret a json acccess demand with several notation
/// classical : json["here"]["and"][10]["there"]
/// dotted : json.here.and[10].there
///
///

/// Wagon runs on rails with two positions behind and inFront and a label
/// for a map :
///   behind is the map, inFront is the value of label attribute
/// for a List:
///   behind is the list, inFront is the value of the label'th position

///
/// solve only the adress of the script a Left Hand Side
/// any = assignation is done outside, using the Wagon return

class jsonNode {
  static final log = Logger('jsonNode');

  /// detects parts separated by points
  /// group(0) with points show.  videos[0].
  /// group(1) without .
  ///
  static final reg_scalp_relax =
      RegExp(r"""(|[\w\d_ \?\s\[\]{}:,"']*)[\.=\s]""");

  ///
  /// at the end of a script could be a function
  static final reg_find_function = RegExp(r"""|(.*\(.*\))""");

  /// detect (several) all index [123] ["abc"] [xxx]?
  ///  group(0) : [xxx]?
  ///  group(1) : 123 "abc" xxx
  ///  group(2) : 123  abc  xxx   // used to get dry name of map entry
  static final reg_all_brackets =
      RegExp(r"""\[(["']?([A-Za-z0-9]*)["']?)]\??""");

  /// isolate var name person[12] or name.  -> person
  static final reg_dry_name = RegExp(r"""^"?([A-Za-z_][A-Za-z_0-9]*)"?""");

  /// find clear  with no parameter
  static final reg_check_clear = RegExp(r"""^clear\s*?\((\s*)\)""");



  // constructor
  jsonNode(this.currentNode, this.aScript);

  String aScript;
  dynamic currentNode, previousNode, advanceEdge;

  /// recursive
  dynamic evaluate() {
    // separates around the dots
    var match = reg_scalp_relax.firstMatch(aScript)?.group(1);
    if (match != null) {
      print('match: $match');
      if (advance(match) == false) return this;
      aScript = aScript.replaceFirst(reg_scalp_relax, "");
      return jsonNode(currentNode, aScript).evaluate();
    }
    // no more match. could be a last part of any kind in script
    if (aScript == "") return this; // no more
    // is that last part a classical, a specific or a function ?

    if (["last", "length", "isEmpty", "isNotEmpty"].contains(aScript)) {
      specialWords(aScript);
      return this;
    }
    var aFunction = reg_find_function.firstMatch(aScript)?.group(1);
    if (aFunction != null) {
      specialFunctions(aFunction);
      return this;
    }
    // else it is a normal last part of a path
    print('last part : $aScript');
    advance(aScript);
    return this;
  }

  ///
  /// progress in a path
  /// separate name and [ ] then advance
  bool advance(String aMatch) {
    var dryName = reg_dry_name.firstMatch(aMatch)?.group(1);
    // search all [xxx]
    if (dryName != null) {
      /*print('- dryName $dryName');*/
      if (advanceOnMap(dryName) == false) return false;
    }
    // we can now advance on index if any
    var bracketsList = reg_all_brackets.allMatches(aMatch);

    for (var block in bracketsList) {
      // check [xxx]? then get xxx and test numeric
      var anIndex = block.group(0);
      /*print('anIndex :$anIndex');*/
      bool nullable = anIndex.endsWith('?');
      // what is between [ ]
      var dryIndex = block.group(1);
      var numericRank = num.tryParse(dryIndex);
      var mapIndex = block.group(2);

      // --- several cases
      if (numericRank != null) {
        if (advanceOnList(numericRank, nullable) == false) return false;
        continue;
      }
      ;
      if (mapIndex != null) {
        if (advanceOnMap(mapIndex) == false) return false;
        continue;
      }
      // wrong things in [ ]
      print(' pas beau les crochets $anIndex');
    }
    return true;
  }

  ///
  ///  progress one step in a Map
  bool advanceOnMap(String aKey) {
    /*print('advanceOnMap $aKey');*/
    bool nullable = aKey.endsWith('?');
    if (nullable) aKey = aKey.substring(0, aKey.length - 1);
    if (currentNode is Map == false) {
      log.warning(
          'try to access $currentNode as a Map with key $aKey. null returned');
      currentNode = null;
      advanceEdge = aKey;
      return false;
    }
    if (currentNode.containsKey(aKey)) {
      previousNode = currentNode;
      currentNode = currentNode[aKey];
      advanceEdge = aKey;
      return true;
    } else {
      previousNode = currentNode; //ie the map
      advanceEdge = aKey;
      currentNode = null;
      return false;
    }
  }

  ///
  /// progress of index in a List
  bool advanceOnList(int rank, bool nullable) {
    /*print(
        'advanceOnList before : $rank on the  ${currentNode.length} ${currentNode.runtimeType} ${beginningOf(currentNode)}');*/
    if ((rank >= 0) && (rank < currentNode.length)) {
      previousNode = currentNode;
      currentNode = currentNode[rank];
      advanceEdge = rank;
      /*print(
          'advanceOnList after : $rank on the ${currentNode.runtimeType} ${beginningOf(currentNode)}');*/
      return true;
    } else {
      // if null expected, no error message
      if (!nullable)
        log.warning(
            'wrong index $rank on the  ${currentNode.length} ${currentNode.runtimeType} ${beginningOf(currentNode)}');
      currentNode = null;
      return false;
    }
  }

/*
 todo : check nullable
 */

  void specialWords(aScript) {
    advanceEdge = aScript;
    switch (aScript) {
      case 'length':
        {
          currentNode = currentNode.length;
        }
        break;
      case 'isEmpty':
        {
          currentNode = currentNode.isEmpty;
        }
        break;
      case 'isNotEmpty':
        {
          currentNode = currentNode.isNotEmpty;
        }
        break;
      case 'last':
        {
          previousNode = currentNode;
          currentNode = currentNode.last;
        }
        break;
      default:
        {
          log.warning('not yet implemented word : $aScript');
        }
    }
  }
  /*
   add, addALL, remove, clear
   */

  void specialFunctions(String aFunction){
    advanceEdge = aFunction;
    if (reg_check_clear.firstMatch(aFunction) != null){
      currentNode.clear();
      return;
    }
    /* others that have parameters are let to caller
    as parameter can involve others components not known here,
    or functions outside the scope of remove, add, addAll
   */
    return;
  }

  ///
  /// for assignments, useful to get the node and the edge in one shot
  dynamic get nodesAndEdge {
    return evaluate();
  }

  ///
  /// if sure to be on a get, do it in one shot
  dynamic get value {
    var x = evaluate();
    return x.currentNode;
  }

  String beginningOf(var someInfo, [int len = 80]) {
    if (someInfo.toString().length < len) len = someInfo.toString().length;
    return someInfo.toString().substring(0, len) + '...';
  }

  @override
  String toString() {
    return ('**previousNode:"${beginningOf(previousNode, 15)}" **currentNode:"${beginningOf(currentNode, 15)}" advanceEdge: "$advanceEdge"');
  }
}
