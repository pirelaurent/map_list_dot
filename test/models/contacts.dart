
class Contacts {

  String mail;
  String tel;

	Contacts.fromJsonMap(Map<String, dynamic> map): 
		mail = map["mail"],
		tel = map["tel"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['mail'] = mail;
		data['tel'] = tel;
		return data;
	}
}
