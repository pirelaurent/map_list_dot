import 'dart:convert';

import 'package:json_xpath/json_xpath.dart';


var source = r"""
{
 "name": "polo",
 "firstName": "marco",
 "birthDate": { "day": 15, "month": 13, "year": 1975 },
 "contacts": [
   { "mail": "ma.po.lo@somewhere.com",  "phone": "01010101" },
   { "mail": "marco@friends.com", "phone": "33333333" }
 ]
}

   """;


void main() {
  var polo = json.decode(source);
  var result = JsonXpath.xpathOnJson(polo, "contacts[1].mail");
  assert(result == 'marco@friends.com', "waiting: marco@friends.com , found $result");
  print('---- end of getByJsonDot test ----');
}
