import 'package:map_list_dot/map_list_dot.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:convert';

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
  //dynamic root = MapList(yamlStructure);
  dynamic root = MapList(json.decode(json.encode(yamlStructure)));

  test('classical query', () {
    assert( jsonNode(root.json, '["show"]["name"]').value == 'quiz on video');
    assert( jsonNode(root.json,'["show"]["videos"][1]["name"]').value == 'japaneese fashion');
    assert( jsonNode(root.json,'["show"]["videos"][1]["questions"][1]["name"]').value == 'games');
    assert( jsonNode(root.json,'["show"]["videos"][1]["questions"][1]["options"][2]["answer"]').value=="go");
    // no change with ? when exists
    assert( jsonNode(root.json,'["show"]?["videos"]?[1]?["questions"]?[1]?["options"]?[2]?["answer"]?').value=="go");
    // when not exist return null without logging error as null expected
    assert( jsonNode(root.json,'["show"]?["videoxx"]?[1]?["questions"]?[1]?["options"]?[2]?["answer"]?').value==null);
  });


  test('classical query starting by a List', () {
    var aJson = [ [1,2,3],[11,12],{"A":"AA","B":"BB"}];

    assert( jsonNode(aJson, '[0][1]').value == 2);
    assert( jsonNode(aJson, '[2]["B"]').value == "BB");
    // wrong index with error message
    assert( jsonNode(aJson, '[0][3]').value == null);
    // wrong index without error message
    assert( jsonNode(aJson, '[0][3]?').value == null);

  });

  test('dot notation query ', () {
    String script = 'show.videos[1].questions[1].name';
    print(script);
    var jse = jsonNode(root.json, script).evaluate();
    print(jse.show());
  });

  test('wrong query ', () {
    var script = '["show"].videos[1].questions[1][10]';
    print(script);
    var jse = jsonNode(root.json, script).evaluate();
    print(jse.show());
  });
}
