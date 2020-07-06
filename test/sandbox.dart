import 'package:map_list_dot/map_list_dot.dart';


void add(String regex, var tokenId, {multiLine:false}){
   print(regex);
}


/// a private place to test some dart syntax
void main() {
  var tokenizer = new Tokenizer(caseSensitive: true);
  tokenizer.add(myLang.STRING, "^['\"](.*)['\"]");


}
