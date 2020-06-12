
void show(var reg, var aString){
  Iterable foundAll = reg.allMatches(aString);
  print('String: $aString');
//  print(foundAll.elementAt(0).group(0));
  for (var ff in foundAll ){
    print(ff.group(0));
  }
  print(foundAll.isNotEmpty);
  if (foundAll.isEmpty){
    print('dry element : $aString');
  }
}


void main() {
  var reg_scalp_relax = RegExp(r"""[a-zA-Z0-9_ \? \[\]"]*[\.=]""");

  var reg_brackets_relax = RegExp(r"""\["?[A-Za-z0-9]*"?]\??""");
  show(reg_scalp_relax,'bikes[1].color.');





  var reg_dry_name = RegExp(r"""^[A-Za-z_][A-Za-z_]*""");
  var reg_rhs = RegExp(r"""[\.=].*""");
  var reg_indexString = RegExp(r"""\[\s*['"]([a-zA-Z0-9\s]*)['"]\]""");

  show(reg_brackets_relax,'bikes?["abc"]?');


/*
  print('-------- isolate parts inital --------------');
  var reg = reg_scalp_relax;
  show(reg, 'person.name.date = 12');
  show(reg, 'person?.name.date = 12');
  show(reg, 'person[0].date = 12');
  show(reg, 'person[0]["name"].truc');
  show(reg, 'person [12][10]?   [0]?[10]?.machin');
  show(reg_rhs, 'person [12][10]?   [0]?[10]?.machin');

  print('----------------------------------');








  //var reg = reg_scalp_relax;

  show(reg,'[12] = 20');
  show( reg, 'person.name.date = 12');

  show(reg,'person[0].name= "toto"');

  show(reg,'person[0].name= "テスト"');

  show(reg,'person[0]["name"]');
  show(reg,'person["name"][0]');
  show(reg,'person [12][10]?  ["name"]?  [0]?[10]?');


  // NOK
  print('------nok -----------');
  show(reg,'person[0][\'name\']');
  show(reg,'person[\'name\']');


 */
}