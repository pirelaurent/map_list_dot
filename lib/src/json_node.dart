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
      RegExp(r'''(|[\w\d_ \?\s\[\]{}:,"']*)[\.=\s]|(.*\(.*\))''');

  ///
  /// at the end of a script could be a function
  static final reg_find_function = RegExp(r'''(.*\(.*\))''');

  /// detect (several) all index [123] ["abc"] [xxx]?
  ///  group(0) : [xxx]?
  ///  group(1) : 123 "abc" xxx
  ///  group(2) : 123  abc  xxx   // used to get dry name of map entry
  /// to distinguish [last] from ["last"] group1 != group2
  static final reg_all_brackets =
      RegExp(r'''\[\s?(["']?([A-Za-z0-9]*)["']?)\s?]\??''');

  /// isolate var name person[12] or name.  -> person
  static final reg_dry_name = RegExp(r'''^"?([A-Za-z_][A-Za-z_0-9]*)"?''');

  /// find clear  with no parameter
  static final reg_check_clear = RegExp(r'''^clear\s*?\((\s*)\)''');

  /// constructor
  ///   call locate to recurse before returning values
  jsonNode(this.toNode, this.aScript, [this.originalScript]) {
    originalScript ??= aScript;
    // copy by hand as we cannot do a return jsn or a this=json
    jsonNode jsn = locate();
    toNode = jsn.toNode;
    fromNode = jsn.fromNode;
    edge = jsn.edge;
  }

  String aScript, originalScript;
  dynamic fromNode, edge, toNode;

  /// recursive
  dynamic locate() {
    if (aScript == '') {
      return this;
    }

    // separates around the dots
    var match = reg_scalp_relax.firstMatch(aScript)?.group(1);
    if (match != null) {
      if (advance(match) == false) {
        return this;
      }
      // clean this part and continue recursively
      aScript = aScript.replaceFirst(reg_scalp_relax, '');
      return jsonNode(toNode, aScript, originalScript);
    }
    /*
     no more match.
     will be the end of recursion.
     the remaining part can be a path or special functions
     */
    if (aScript == '') return this;

    if (['last', 'length', 'isEmpty', 'isNotEmpty'].contains(aScript)) {
      specialWords(aScript);
      // end of recurse
      return this;
    }
    // .clear() only
    if (reg_check_clear.firstMatch(aScript)?.group(1) != null) {
      toNode.clear();
      return this;
    }
    /*
     if other function call with parameter
     must be done at an upper level
     jsonNode is only a locator of data or subtree
     */
    if (reg_find_function.firstMatch(aScript)?.group(1) != null) {
      edge = aScript;
      return this;
    }
    // else it is a normal last part of a path
    advance(aScript);
    return this;
  }

  ///
  /// progress in a path
  /// separate name and [ ] then advance
  bool advance(String aMatch) {
    if (aMatch.startsWith('"')) {
      log.warning(
          'Avoid to use quotes around notation : $aMatch in $originalScript');
    }
    var dryName = reg_dry_name.firstMatch(aMatch)?.group(1);
    // first apply a map name key if any except .last
    if (dryName == 'last') {
      specialWords(dryName);
      return true;
    }

    if (dryName != null) {
      if (advanceOnMap(dryName) == false) return false;
    }
    // we can now advance on index if any
    var bracketsList = reg_all_brackets.allMatches(aMatch);

    for (var block in bracketsList) {
      // check [xxx]? then get xxx and test numeric
      var anIndex = block.group(0);
      var dryIndex = block.group(1); // with quotes
      var mapIndex = block.group(2); // without
      var nullable = anIndex.endsWith('?');
      // what is between [ ]

      var numericRank = num.tryParse(dryIndex);
      // could also be [last] index in the middle of a chain
      if (dryIndex == 'last') {
        if (toNode is List) {
          numericRank = toNode.length - 1;
        }
      }

      // --- several cases
      if (numericRank != null) {
        if (advanceOnList(numericRank, nullable) == false) {
          return false;
        }
        continue;
      }
      if (mapIndex != null) {
        if (advanceOnMap(mapIndex) == false) {
          return false;
        }
        continue;
      }
      // wrong things in [ ]
      print('**** ugly brackets within $anIndex ****');
    }
    return true;
  }

  ///
  ///  progress one step in a Map
  bool advanceOnMap(String aKey) {
    var nullable = aKey.endsWith('?');
    if (nullable) aKey = aKey.substring(0, aKey.length - 1);
    if (toNode is Map == false) {
      log.warning(
          'try to access $toNode as a Map with key $aKey. null returned');
      toNode = null;
      edge = aKey;
      return false;
    }
    if (toNode.containsKey(aKey)) {
      fromNode = toNode;
      toNode = toNode[aKey];
      edge = aKey;
      return true;
    } else {
      fromNode = toNode; //ie the map
      edge = aKey;
      toNode = null;
      return false;
    }
  }

  ///
  /// progress of index in a List
  bool advanceOnList(int rank, bool nullable) {
    fromNode = toNode;
    if ((rank >= 0) && (rank < toNode.length)) {
      toNode = toNode[rank];
      edge = rank;
      /*print(
          'advanceOnList after : $rank on the ${lastNode.runtimeType} ${beginningOf(currentNode)}');*/
      return true;
    } else {
      // if null expected, no error message
      if (!nullable) {
        log.warning(
            'wrong index $rank on the ${toNode.runtimeType} ${beginningOf(toNode)}');
      }
      toNode = null;
      return false;
    }
  }

/*
 todo : check nullable
 */

  void specialWords(aScript) {
    edge = aScript;
    switch (aScript) {
      case 'length':
        {
          fromNode = toNode;
          // set result as an int
          toNode = toNode.length;
        }
        break;
      case 'isEmpty':
        {
          toNode = toNode.isEmpty;
        }
        break;
      case 'isNotEmpty':
        {
          toNode = toNode.isNotEmpty;
        }
        break;
      case 'last':
        {
          fromNode = toNode;
          if (fromNode is List) {
            toNode = toNode.last;
            edge = fromNode.length - 1;
          } else {
            log.warning(
                'calling "last" must be on a List. Here is on a ${fromNode.runtimeType} . null returned');
            toNode = null;
          }
        }
        break;
      default:
        {
          log.warning('not yet implemented word : $aScript');
        }
    }
  }

  ///
  /// if sure to be on a get, do it in one shot
  /// otherwise use locate and check nodes
  dynamic get value {
    return toNode;
  }

  static String beginningOf(var someInfo, [int len = 80]) {
    var dot3 = '...';
    if (someInfo.toString().length < len) {
      len = someInfo.toString().length;
      dot3 = '';
    }
    return someInfo.toString().substring(0, len) + dot3;
  }

  @override
  String toString() {
    return ('${simplifiedType(fromNode)}${beginningOf(fromNode, 15)}  --- $edge -> ${simplifiedType(toNode)} ${beginningOf(toNode, 15)}  ');
  }

  String simplifiedType(dynamic node) {
    if (node is Map) return '(map)';
    if (node is List) return '(list)';
    return ('(${node.runtimeType.toString()})');
  }
}
