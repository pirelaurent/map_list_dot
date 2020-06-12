
void show(var reg, var aString){
  Iterable foundAll = reg.allMatches(aString);
  print(aString);
  for (var ff in foundAll ){
    print(ff.group(0));
  }
  print(foundAll.isNotEmpty);
}


void main(){

  var reg_brackets_relax= RegExp(r"""\["?[A-Za-z0-9]*"?]""");
  var reg = reg_brackets_relax;
  show(reg,'person[0][12]["name"]');
  show(reg,'person[0]["name"]');
  show(reg,'person["name"][0]');
  show(reg,'person  ["name"]  [0]');


  // NOK
  print('------nok -----------');
  show(reg,'person[0][\'name\']');
  show(reg,'person[\'name\']');

}