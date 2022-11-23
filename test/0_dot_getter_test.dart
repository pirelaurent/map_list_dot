import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'dart:convert';

/*
  Generalize assert to show what is the received response against the expected
 */
void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}

/*
 basic tests on get .
 Notice that you can call directly exec
 but it doesn't verify if set or get,it just apply the script
 */
void main() {
  // set a logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  /*
   read a yaml file , change it to json
   */
  var testFile =
      path.join(Directory.current.path, 'models', 'yaml', 'quiz.yaml');
  var file = File(testFile);
  var yamlString = file.readAsStringSync();
  var yamlStructure = loadYaml(yamlString);
  var jsonFromYaml = json.decode(json.encode(yamlStructure));
  // warning : leaving in YamlMap & YamlList makes a read only structure
  // but getter still ok, not setters
  dynamic root = MapList(jsonFromYaml);

  test("direct access with classical notation", () {
    // --- verify still working with standard notation
    // root has been loaded with maps and lists
    assert(root["show"]["name"] == "quiz on video");
    assert(root["show"]["videos"][1]["name"] == "japanese fashion");
    assert(root["show"]["videos"][1]["questions"][1]["name"] == "games");
    assert(
        root["show"]["videos"][1]["questions"][1]["options"][2]["answer"] ==
        "go");
  });

  test("access to structure with dot notation", () {
    // --- now the same with a dot notation
    assert(root.show.name=="quiz on video");
    assert(root.show.videos[1].name =="japanese fashion");
    assert(root.show.videos[1].questions[1].name =="games");
    assert(root.show.videos[1].questions[1].options[2].answer =="go");
  });

  test("access with classical and dot notation in interpreter ", () {
    dynamic root = MapList(jsonFromYaml);
    // check access on jsonNode only . value is same as toNode
    assert( jsonNode(root.json,'["show"]["name"]').value == 'quiz on video');
    assert(jsonNode(root.json,'show.name').toNode == 'quiz on video');
    // now check access through MapList
    assert(root.eval('show.name') == "quiz on video");
    assert(root.eval('show.videos[1].name')=='japanese fashion');
    assert(root.eval('show.videos[1].questions[1].name')=='games');
    assert(root.eval('show.videos[1].questions[1].options[2].answer')=='go');
  });

  test("access with standard notation in interpreter", () {
    dynamic root = MapList(jsonFromYaml);
    assert(root.eval('["show"]["name"]') == "quiz on video");
    assert(root.eval('["show"]["videos"][1]["name"]') == "japanese fashion");
    assert(
        root.eval('["show"]["videos"][1]["questions"][1]["name"]') == "games");
    assert(
        root.eval(
            '["show"]["videos"][1]["questions"][1]["options"][2]["answer"]') ==
        "go");
  });

  test("access with a dumb mix of direct and interpreted notation", () {
    /*
     warning : cannot mix notation if staying in a yaml Structure.
     Mandatory to convert first:
     */
    dynamic root = MapList(json.decode(json.encode(yamlStructure)));
    // --- now the same with a dot notation
    //print(root.eval('show').runtimeType);
    assert(root.eval('show').name =="quiz on video");
    assert(root.show.eval('videos[1]["name"]')== "japanese fashion");
    assert(root.show.eval('["videos"][1]').questions[1].name == "games");
    assert(root.show.videos[1].eval('questions[1]').options[2].answer == "go");
    assert(root.show.videos[1].eval('questions[1].options[2]').answer == "go");
  });
}
