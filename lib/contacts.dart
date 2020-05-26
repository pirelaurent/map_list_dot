
class Contact {

  String mail;
  String phone;

	Contact.fromJsonMap(Map<String, dynamic> map):
		mail = map["mail"],
		phone = map["phone"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['mail'] = mail;
		data['phone'] = phone;
		return data;
	}
}
