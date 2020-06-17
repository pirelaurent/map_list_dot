//import 'package:map_lib_dot/src/map_list.dart';
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

  // use the Yaml file in yaml dir
  var testFile =
      path.join(Directory.current.path, 'test', 'models', 'yaml', 'quiz.yaml');
  var file = File(testFile);
  var yamlString = file.readAsStringSync();
  var yamlStructure = loadYaml(yamlString);
  // warning : leaving in YamlMap & YamlList makes a read only structure
  // but getter still ok, not setters
  dynamic root = MapList(yamlStructure);

  test("direct access with standard notation", () {
    // --- verify still working with standard notation
    // root has been loaded with maps and lists
    assertShow(root["show"]["name"], "quiz on video");
    assertShow(root["show"]["videos"][1]["name"], "japaneese fashion");
    assertShow(root["show"]["videos"][1]["questions"][1]["name"], "games");
    assertShow(
        root["show"]["videos"][1]["questions"][1]["options"][2]["answer"],
        "go");
  });

  test("access to structure with dot notation", () {
    // --- now the same with a dot notation
    assertShow(root.show.name, "quiz on video");
    assertShow(root.show.videos[1].name, "japaneese fashion");
    assertShow(root.show.videos[1].questions[1].name, "games");
    assertShow(root.show.videos[1].questions[1].options[2].answer, "go");
  });

  test("access with dot notation in interpreter ", () {
    dynamic root = MapList(yamlStructure);
    assertShow(root.get("show.name"), "quiz on video");
    assertShow(root.get("show.videos[1].name"), "japaneese fashion");
    assertShow(root.get("show.videos[1].questions[1].name"), "games");
    assertShow(root.get("show.videos[1].questions[1].options[2].answer"), "go");
  });

  test("access with standard notation in interpreter", () {
    dynamic root = MapList(yamlStructure);
    assertShow(root.get('["show"]["name"]'), "quiz on video");
    assertShow(root.get('["show"]["videos"][1]["name"]'), "japaneese fashion");
    assertShow(
        root.get('["show"]["videos"][1]["questions"][1]["name"]'), "games");
    assertShow(
        root.get(
            '["show"]["videos"][1]["questions"][1]["options"][2]["answer"]'),
        "go");
  });

  test("access with a dumb mix of direct and interpreted notation", () {
    dynamic root = MapList(yamlStructure);
    // --- now the same with a dot notation
    assertShow(root.get('show').name, "quiz on video");
    assertShow(root.show.get('videos[1]["name"]'), "japaneese fashion");

    //print(root.show.get('["videos"][1]'));

    assertShow(root.show.get('["videos"][1]').questions[1].name, "games");
    assertShow(root.show.videos[1].get('questions[1].options[2]').answer, "go");
  });

  test(" Yaml loader generates read only data", () {
    dynamic root = MapList(yamlStructure);
    try {
      root.show.name = "new video title";
    } catch (e) {
      assert(e.toString() ==
          'Unsupported operation: Cannot modify an unmodifiable Map');
    }
    root = MapList(json.decode(json.encode(yamlStructure)));
    root.show.name = "new video title";
    assert(root.show.name == "new video title");
  });
}
