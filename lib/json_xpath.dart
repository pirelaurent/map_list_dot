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
   extractor shared method
   */
  static dynamic xpathOnJson(var someJson, String compositeProperty) {
    var returnedValue;
    dynamic root = someJson;
    // split parts separated by the dots
    var parts = compositeProperty.split('.');
    for (var aPart in parts) {
      // in case of a xxxxx[nn] split in clean xxxxx and rank nn
      var rank;
      var found = RegExp('\\[[0-9]*\\]').firstMatch(aPart);
      if (found != null) {
        var result = found.group(0); // [1]
        rank = num.tryParse(result.substring(1, result.length - 1));
        // clean the string to have the dry List name
        aPart = aPart.replaceAll(found.group(0), '');
      }
      // case of a very beginning as List: dry [0].
      if (aPart =="") returnedValue = root;
      else returnedValue = root[aPart];
      // could be another Map, a List or a simple value
      if (returnedValue is Map) {
        root = returnedValue;
        continue;
      }
      if (returnedValue is List) {
        // for no index or wrong index, return the List ans stop evaluation
        if (rank == null) break;
        if ((rank < 0) || (rank > returnedValue.length)) break;
        // valid index, take this entry if a continuation
        root = returnedValue[rank];
        returnedValue = returnedValue[rank];
        continue;
      }
    }
    return returnedValue;
  }
}
