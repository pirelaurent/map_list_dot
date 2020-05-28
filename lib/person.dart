import 'package:json_xpath/json_xpath.dart';

import 'birth_date.dart';
import 'contacts.dart';


class Person with JsonXpath{

  String name;
  String firstName;
  BirthDate birth_Date;
  List<Contact> contacts;


	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['name'] = name;
		data['firstName'] = firstName;
		data['birth_Date'] = birth_Date == null ? null : birth_Date.toJson();
		data['contacts'] = contacts != null ? 
			this.contacts.map((v) => v.toJson()).toList()
			: null;
		return data;
	}

	Person.fromJsonMap(Map<String, dynamic> map):
				name = map["name"],
				firstName = map["firstName"],
				birth_Date = BirthDate.fromJsonMap(map["birth_Date"]),
				contacts = List<Contact>.from(map["contacts"].map((it) => Contact.fromJsonMap(it)));
}
