//import 'package:map_lib_dot/src/map_list.dart';
import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/*
  if wrong test , show what was expected and what we got
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
  var testFile =
      path.join(Directory.current.path, 'test', 'models', 'yaml', 'quiz.yaml');
  var file = File(testFile);
  var yamlString = file.readAsStringSync();
  var xYaml = loadYaml(yamlString);
  dynamic root = MapList(xYaml);

  test("direct access with standard notation", () {
    // --- verify still working with standard notation
    assertShow(root["show"]["name"], "quiz on video");
    assertShow(root["show"]["videos"][1]["name"], "japaneese fashion");
    assertShow(root["show"]["videos"][1]["questions"][1]["name"], "games");
    assertShow(
        root["show"]["videos"][1]["questions"][1]["options"][2]["answer"],
        "go");
  });

  test("access to structure dot notation", () {
    // --- now the same with a dot notation
    assertShow(root.show.name, "quiz on video");
    assertShow(root.show.videos[1].name, "japaneese fashion");
    assertShow(root.show.videos[1].questions[1].name, "games");
    assertShow(root.show.videos[1].questions[1].options[2].answer, "go");
  });

  test("access to structure dot notation with exec", () {
    dynamic root = MapList(xYaml);
    // --- now the same with a dot notation
    assertShow(root.get("show.name"), "quiz on video");
    assertShow(root.get("show.videos[1].name"), "japaneese fashion");
    assertShow(root.get("show.videos[1].questions[1].name"), "games");
    assertShow(
        root.get("show.videos[1].questions[1].options[2].answer"), "go");
  });

  test("access to structure classic notation with exec", () {
    dynamic root = MapList(xYaml);
    // --- now the same with a dot notation
    assertShow(root.get('["show"]["name"]'), "quiz on video");
    assertShow(
        root.get('["show"]["videos"][1]["name"]'), "japaneese fashion");
    assertShow(
        root.get('["show"]["videos"][1]["questions"][1]["name"]'), "games");
    assertShow(
        root.get(
            '["show"]["videos"][1]["questions"][1]["options"][2]["answer"]'),
        "go");
  });

  test("access to structure with a dumb mix of notation with exec", () {
    dynamic root = MapList(xYaml);
    // --- now the same with a dot notation
    assertShow(root.get('show["name"]'), "quiz on video");
    assertShow(root.get('["show"].videos[1]["name"]'), "japaneese fashion");
    assertShow(root.get('show["videos"][1].questions[1].name'), "games");
    assertShow(
        root.get('["show"]["videos"][1].questions[1].options[2]["answer"]'),
        "go");
  });
}
