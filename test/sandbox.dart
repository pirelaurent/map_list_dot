import 'package:map_list_dot/map_list_dot.dart';


void main(){
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });


 /* dynamic root = MapList();

  root = MapList();
  root.exec('contacts= []');
  root.exec('contacts.add({"name":"polo"})');
  print(root);
  root.exec('contacts[last].addAll{"firstName" : "marco", "birthDate" = "15/09/1254"}');
  print(root);


  root.exec('squad = {}'); // create a new map entry at root
  root.exec('squad.name = "Super hero squad"'); // String with '" "'
  root.exec("squad.homeTown = 'Metro City'");   // String with "' '"
  root.exec('squad.formed = 2016');             // int
  root.exec('squad.active = true');             // bool
  root.exec('squad.score = 38.5');              // double
  root.exec('squad.members = []');              // add an empty list
// adding another set of data at root
  root.exec('car = {"name":"Ford", "color":"white"}'); // create and set with json-like string.
  root.exec('car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false})'); //add or merge with function addAll
  root.exec('squad.members = [1,2,3,4]');
  root.exec('squad.members.length = 2');
  //root.exec('squad.length = 2'); ** trying to set length on a squad.length. which is not a List no action done.
  //root.exec('squad."name" = "Super hero squad"'); // cannot access a String with a key like

  //print(root.exec('squad.members.length'));
  print(root.squad.members);
*/



}