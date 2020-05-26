import 'package:json_xpath/json_xpath.dart';

import 'birth_date.dart';
import 'contacts.dart';


class Person with JsonXpath{

  String name;
  String firstName;
  BirthDate birthDate;
  List<Contact> contacts;


	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['name'] = name;
		data['firstName'] = firstName;
		data['birthDate'] = birthDate == null ? null : birthDate.toJson();
		data['contacts'] = contacts != null ? 
			this.contacts.map((v) => v.toJson()).toList()
			: null;
		return data;
	}

	Person.fromJsonMap(Map<String, dynamic> map):
				name = map["name"],
				firstName = map["firstName"],
				birthDate = BirthDate.fromJsonMap(map["birthDate"]),
				contacts = List<Contact>.from(map["contacts"].map((it) => Contact.fromJsonMap(it)));
}
