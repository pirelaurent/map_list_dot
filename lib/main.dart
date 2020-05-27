import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:io';

/*
 from beginning
 letter, digit in any number
 optional [ digits optional .. digits   ]
 end by a dot
 */
var scalp = RegExp("^[a-z0-9]*(\\[[0-9]*(\\.\\.)?[0-9]*\\])?\\.");
// [1..23]
var brackets = RegExp("\\[[0-9.]*\\]");
/*
 we enter with a json wher we go step after step
 */
dynamic loop(var jsonStep, String path) {
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
    print('rawrank: $rawRank');
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
    */
  jsonStep = jsonStep[item];
  /*
      if we are NOT on a list
      at the end return entry
      otherwise go on
     */
  if (!(jsonStep is List)) {
    if (path == "") {
      return jsonStep;
    } else {
      return (loop(jsonStep, path));
    }
  }
  /*
    if a List without brackets
    if final like .contact          :returns the List
    if on the way .contact.mail : loop on the list
    */
  if (first == null) {
    if (path == "") return jsonStep;
    List resu = [];
    for (var anElement in jsonStep) {
      resu.add(loop(anElement, path));
    }
    return resu;
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
      return loop(jsonStep[first], path);
  }
  /*
     if a range .. verify and loop
     */
  if ((last < first) && (last > jsonStep.length)) return null;
  List resu = [];
  for (int i = first; i <= last; i++) {
    if (path == "")
      resu.add(jsonStep[i]);
    else
      resu.add(loop(jsonStep[i], path));
  }
  return resu;
}

var test = [
  //"store",
  //"store.book",
  //"store.book[2]",
  //"store.book[2].author",
  //"store.book.author",
  "store.book[1..3].price"
];





void main() {
  var testFile =
      p.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  var jsonStore = json.decode(jsonString);
  //print(jsonStore);

  for (var aTest in test) {
    print('---------------------------');
    var resu = loop(jsonStore, aTest);
    print("===> ${resu.runtimeType} :  \n $resu");
  }
}
