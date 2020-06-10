//import 'package:map_lib_dot/src/map_list.dart';
import 'package:map_list_dot/map_list_dot_lib.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}

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


  test("access to structure dot notation with script ", () {
    // --- now the same with a dot notation
    assertShow(root.script("show.name"), "quiz on video");
    assertShow(root.script("show.videos[1].name"), "japaneese fashion");
    assertShow(root.script("show.videos[1].questions[1].name"), "games");
    assertShow(
        root.script("show.videos[1].questions[1].options[2].answer"), "go");
  });

}
