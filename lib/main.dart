import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:io';
import 'package:json_xpath/json_xpath.dart';

var test = [
  //"store",
  //"store.book",
  //"store.book[2]",
  //"store.book[2].author",
  "store.book.isbn10",
  "store.book[1..2].cover",
  "store.book[250]"
];





void main() {
  var testFile =
      p.join(Directory.current.path, 'test', 'models', 'json', 'store.json');
  var file = File(testFile);
  var jsonString = file.readAsStringSync();
  var jsonStore = json.decode(jsonString);
  print(jsonStore);

  //print(jsonStore);

  JsonXpath.withNull = true;

  for (var aTest in test) {
    print('---------------------------');
    var resu = JsonXpath.xpathOnJson(jsonStore, aTest);
    print("===> ${resu.runtimeType} :  \n $resu");
  }
}
