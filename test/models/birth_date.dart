
class BirthDate {

  int day;
  int month;
  int year;

	BirthDate.fromJsonMap(Map<String, dynamic> map): 
		day = map["day"],
		month = map["month"],
		year = map["year"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['day'] = day;
		data['month'] = month;
		data['year'] = year;
		return data;
	}
}
