///
/// Only a bunch of pseudo text messages
/// Traps already practised :
///   leaving // comments in the message
///   leaving dart continuation symbol , at the end of a collection

String fakeMessage1() {
  return
  '''
  persons.add({
  "name": "Polo",
  "firstName": "Marco",
  "birthDate": {
  "day": 15,
  "month": 9,
  "year": 1254
  },
    "cards": [{
      "mail": "ma.po.lo@china.com",
      "phone": "+99 01 02 03 04 05"
    },
      {
        "mail": "marco@venitia.com",
        "phone": "+00 99 98 97 96 95"
      },
      {
        "mail": "polo@water.com"
      }
    ]
  });
  ''';
}

String fakeMessage2() {
  return '''
     persons.add({
    "name": "Magellan",
    "firstName": "Fernando",
    "birthDate": {
      "day": 15,
      "month": 3,
      "year": 1480
    },
    "cards": [
      {
        "mail": "fern.mag@chile.com",
        "phone": "123456789"
      },
      {
        "mail": "fernando@porto.com",
        "phone": "7777777"
      }
    ]
  })
    ''';
}
