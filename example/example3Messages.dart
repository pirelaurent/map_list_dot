// don't leave comment in the message

String fakeMessage1() {
  return
  '''
  persons.add({
  "name": "Polo",
  "firstName": "marco",
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
