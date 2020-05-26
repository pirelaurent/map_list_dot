import 'dart:convert';
import 'json_xpath.dart';

class JsonObject with JsonXpath{
  var _data;
  // constructor with a structured Maps and Lists
  JsonObject(this._data);
  // constructor with a String in json format
  JsonObject.fromString(String message){
    _data = json.decode (message);
  }
  dynamic toJson() => _data;
}

