import 'dart:convert';

import 'package:json_xpath/Person.dart';

var src1 = r"""
{
  "name": "polo",
  "firstName": "marco",
  "birthDate": { "day": 15, "month": 9, "year": 1254
  },
  "contacts": [
    { "mail": "ma.po.lo@china.com",  "phone": "987654321" },
    { "mail": "marco@venitia.com", "phone": "33333333" }
  ]
}
 """;
var src2 = """
{
  "name": "Magellan",
  "firstName": "Fernando",
  "birthDate": { "day": 15, "month": 3, "year": 1480
  },
  "contacts": [
    { "mail": "fern.mag@chile.com",  "phone": "123456789" },
    { "mail": "fernando@porto.com", "phone": "7777777" }
  ]
} """;

void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}

void main() {
  Person who1 = Person.fromJsonMap(json.decode(src1));
  Person who2 = Person.fromJsonMap(json.decode(src2));

  assertShow(who1.xpath('birthDate.year'), 1254);
  assertShow(who2.xpath('birthDate.month'), 3);

  assertShow(who1.xpath('contacts[1].mail'),'marco@venitia.com');

}
