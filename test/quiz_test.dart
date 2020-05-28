import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:convert';
import 'package:json_xpath/JsonObject.dart';
import 'package:test/test.dart';

/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected, "expected: $expected got: $what");
}


void main() {
  var testFile =
  p.join(Directory.current.path, 'test', 'models', 'yaml', 'quiz.yaml');
  var file = File(testFile);
  var yamlString = file.readAsStringSync();
  var xYaml = loadYaml(yamlString);
  var aShow = JsonObject(xYaml);

  test("direct access to yaml structure ", () {

    assert(aShow.xpath('show.name') == 'quiz on video');
    assert(aShow.xpath('show.videos.name').toString() ==
        '[introduction, japaneese fashion, Martial Arts, Fish preparation]');
    //print(aShow.xpath('show.videos.questions.name').toString());
    assert(aShow.xpath('show.videos.questions.name').toString() ==
        '[[clothes, games, plants], [fighting, characters, divine wind], [fish]]');
    assert(aShow.xpath('show.videos.questions[2].options.answer').toString() ==
        '[[Bonsaï, Hara-kiri, Kaki], [Kamikaze, Tsunami, Karaoke]]');
  });

  test("relay on intermediate JsonObject ", () {
    /*
  we can relay on a result and make a new JsonObject
   */
    var question = JsonObject(aShow.xpath('show.videos[2].questions[0]'));
    assert( question.xpath('name') == 'fighting', question.xpath('name'));
    assert( question.xpath('options.answer').toString() ==
        '[judo, jujitsu, sumo, keirin]');
  });
}