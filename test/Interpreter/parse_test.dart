import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
var scriptsBool = [
  'true',
  'false',
  'truelle = 20',
  'marytrue ="hello"',
  'falseSecond = false;',
  '(toto == true)',
  '(toto ==true  )',
  'if(true) then false;',
  'true==false',
  '   (true);',
];

var scriptAssign = [
  'book[4].author',
  "homeTown = 'Metro City'",
  'homeTown = "Metro City"',
  'homeTown = "Metro City" # this is a comment ',
  'formed = 2016',
  'active = true',
  'score = 38.5',
  '''/*
    this is a very large comment 
    preceding a composite variable name 
    */   
      ''',
  'if (igenie == 12);',
  'ifigenie = "helllo"',
  'persons.last.categories',
  'book[4].author',

  'persons.last.categories = persons[0].categories',
  'members[0].powers[1][12] = "Turning heavy"',
  // warning regex not able to find  missing "
  'members["toto"].powers["zaza"] [10]',
  'persons.last.categories.contains(categories.adventurer)',
];

var scriptJson = [
 ' langDict = {"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }}',
  'categories = {}',
  '={"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }}',
  'categories.addAll({"contemporary": 0, "popular": 1, "adventurer": 2, "artist": 3})',


];


var scriptsCompare = [
  'true',
  'false',
  'true || false',
  'true && false',
  'true && true',
  'false && false',
  "(homeTown == 'Metro City')",
  '(homeTown == "Metro City")',
  '(formed == 2016)',
  '(active == true )',
  '(score == 38.5)',
  '(score > 38.5)',
  '(score >= 38.5)',
  '(score < 38.5)',
  '(score <= 38.5)',
  '(score != 38.5)',
  '(score == 38.5)&&(homeTown == "Metro City")',
  '(score == 38.5)||(homeTown == "Metro City")',
];

void main() {
  var tokenizer = Grammar().tokenizer;

  test('distinguish true false from variables ', () {
    var nbTrue = 0;
    var nbFalse = 0;
    for (var aScript in scriptsBool) {
      print('$aScript');
      tokenizer.tokenize(aScript);
      for (Token token in tokenizer.tokens) {
        if (token.tokenId == myLang.BOOLEAN) {
          if (token.text == 'true')
            nbTrue++;
          else if (token.text == 'false') nbFalse++;
        }
      }
    }
    assert(nbTrue == 6, 'found : $nbTrue');
    assert(nbFalse == 4, 'found : $nbFalse');
  });

  test('assignments variable and values', () {
    var nbVariable = 0;
    for (var aScript in scriptAssign) {
      print('$aScript');
      tokenizer.tokenize(aScript);
      for (Token token in tokenizer.tokens) {
        print(' $token');
      }
    }
  });
  test('identify json ',(){
    for (var aScript in scriptJson) {
      print('$aScript');
      tokenizer.tokenize(aScript);
      for (Token token in tokenizer.tokens) {
        print(' $token');
      }
    }
  });



}

