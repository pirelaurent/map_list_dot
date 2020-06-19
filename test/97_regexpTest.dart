
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


final RegExp reg_clean_out_assignment = RegExp(r"""[\("'{].*[\('"\)}]""");
final reg_check_add_addAll = RegExp(r"""((.add\(.*\)|.addAll\(.*\))""");

 List split_lhs_rhs (String aScript){
  String lhs, rhs;

  // first clean function parameters between
  var aScriptCleaned= (aScript.replaceAll(reg_clean_out_assignment,""));
  // search =
  var equalsPos = aScriptCleaned.indexOf('=');
  if (equalsPos != -1 ){
    lhs = aScript.substring(0,equalsPos);
    rhs = aScript.substring(equalsPos);
  }
  else {
    rhs= null;
    lhs = aScript;
  }
  print('lhs: $lhs   rhs: $rhs');
  return [lhs,rhs];
}


void main() {
   var s;
   var result, rhs, lhs;
  s= 'contacts[last].addAll({"firstName" : "marco", "birthDate" = "15/09/1254"})';
  split_lhs_rhs(s);
  lhs = result[0]; print(lhs);
  rhs = result[0]; print(rhs);

   s= 'members[0].powers[1] = "Turning heavy"';
   split_lhs_rhs(s);
  s='dico.FR[2] = "comment = va"';
   split_lhs_rhs(s);
    s='[1] = 33';
   split_lhs_rhs(s);

   s = '';





 return;



}

