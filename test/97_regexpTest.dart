import 'package:map_list_dot/map_list_dot_lib.dart';
void show(var reg, var aString){
  Iterable foundAll = reg.allMatches(aString);
  print('String: $aString');
  for (var ff in foundAll ){
    print(ff.group(1));
  }
}


void main() {
  var s;
  s = "show.videos[1].questions[1].options[2].answer";
  show(MapList.reg_scalp_relax,s+'.');

}