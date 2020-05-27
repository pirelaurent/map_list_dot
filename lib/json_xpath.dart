abstract class JsonXpath {
  /*
   methods to implements by followers
  must return data as a json (Maps and Lists)
   */
  dynamic toJson();
  /*
    mixin method to simplify usage
   */
  dynamic xpath(String aPath) => JsonXpath.xpathOnJson(this.toJson(), aPath);

/*
 from beginning
 letter, digit in any number
 optional [ digits optional .. digits   ]
 end by a dot
 */
  static final scalp = RegExp("^[a-zA-Z0-9]*(\\[[0-9]*(\\.\\.)?[0-9]*\\])?\\.");
// [1..23]
  static final brackets = RegExp("\\[[0-9.]*\\]");
  /*
   indicates if null values are returned in Lists or not
   useful to see missing values .price [12.99,null,8.99]
   by default false : .price [12.99,8.99]
   */
  static bool withNull = false;

  static dynamic xpathOnJson(var jsonStep, String path) {
    path = path.trim();
    var item;
    var found = scalp.firstMatch(path);
    /*
    if found part of path  xxxx.
    take it, remove the dot at the end
   */
    if (found != null) {
      item = found.group(0);
      path = path.replaceAll(item, '');
      item = item.substring(0, item.length - 1);
    } else {
      item = path;
      path = path.replaceAll(item, '');
    }
    /*
    is this item with brackets []?
    if yes, note ranks
   */
    int first, last;
    found = brackets.firstMatch(item);
    if (found != null) {
      var rawRank = found.group(0);
      // clean the item
      item = item.replaceAll(rawRank, '');
      // remove brackets
      rawRank = rawRank.substring(1, rawRank.length - 1);
      // could be [] [2] [1..2]
      var pos = rawRank.split('..');
      if (pos.length >= 1) first = num.tryParse(pos[0]);
      if (pos.length == 2) {
        last = num.tryParse(pos[1]);
      }
    }
    /*
    now we have a name of an item with optionaly a rank
    in special case, where a json begin as a list (not as a Map)
    first item is missing.
    */

    if (item !="")jsonStep = jsonStep[item];

    // not found wrong item
    if (jsonStep == null) return null;
    /*
      if we are NOT on a list
      at the end return entry
      otherwise go on
     */
    if (!(jsonStep is List)) {
      if (path == "") {
        return jsonStep;
      } else {
        return (xpathOnJson(jsonStep, path));
      }
    }
    /*
    if a List without brackets
    if final like .contact          :returns the List
    if on the way .contact.mail : loop on the list
    */
    if (first == null) {
      if (path == "") return jsonStep;
      List res = [];
      for (var anElement in jsonStep) {
        var back =xpathOnJson(anElement, path);
        if (! withNull && (back==null)) continue;
        res.add(back);
      }
      if (res.isEmpty) return null; else return res;
    }
    /*
    with a value between brackets
    verify range
    */
    if ((first < 0) || (first > jsonStep.length)) return null;
    /*
     if only one element, take it and continue
     */
    if (last == null) {
      if (path == "")
        return jsonStep[first];
      else
        return xpathOnJson(jsonStep[first], path);
    }
    /*
     if a range .. verify and loop
     */
    if ((last < first) || (last > jsonStep.length)) return null;
    List res = [];
    for (int i = first; i <= last; i++) {
      if (path == "")
        {res.add(jsonStep[i]);}
      else
        { var back =xpathOnJson(jsonStep[i], path);
          if (! withNull && (back==null)) continue;
          res.add(back);
        }
    }
    if (res.isEmpty) return null; else return res;
  }
}




