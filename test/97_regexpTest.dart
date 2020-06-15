import 'package:map_list_dot/map_list_dot.dart';
void show(var reg, var aString){
  Iterable foundAll = reg.allMatches(aString);
  print('String: $aString');
  for (var ff in foundAll ){
    print(ff.group(1));
  }
}
/*
 with this regex,
 A match:
 group(1) : anything in quote
 group(2) : equal sign, out of quotes

 */
bool foundEqualsTest(String aScript){
  print('============> $aScript');
  var itEquals = MapList.reg_equals_outside_quotes.allMatches(aScript);
  if (itEquals == null) return false;
  bool seeEquals = false;
  for(var x in itEquals){
   print('---');
    print('0: ${x.group(0)}');
    print('1: ${x.group(1)}');
    print('2: ${x.group(2)}');
    if (x.group(2)=='='){
      seeEquals = true;
    }
}
  return seeEquals;
}


void main() {
  var s;
  s = "show.videos[1].questions[1].options[2].answer";
  //show(MapList.reg_scalp_relax,s+'.');

  s = "homeTown = 'Metro City'";
  assert(MapList.foundEqualsSign(s));
  s = " = {}";
  assert(MapList.foundEqualsSign(s));
  s= 'polo.truc[1].machin = "abcd"';
  assert(MapList.foundEqualsSign(s));
  s= 'polo.truc[1].machin.["abcd"]';
  assert(MapList.foundEqualsSign(s)==false);
  s='';
  assert(MapList.foundEqualsSign(s)==false);
  s=' polo["var x= 12"].truc.20Abd["===="]';
  assert(MapList.foundEqualsSign(s)==false);
  s=' polo["var x= 12"].truc.20Abd["===="] = "abc=23"';
  assert(MapList.foundEqualsSign(s));
}

