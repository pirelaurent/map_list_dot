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


void main(){
  var testFile =
  p.join(Directory.current.path, 'test', 'models', 'yaml', 'survey.yaml');
  var file = File(testFile);
  var yamlString = file.readAsStringSync();
  var xYaml = loadYaml(yamlString);

  var survey = JsonObject(xYaml);

  test("---- test from models.yaml direct----", (){
    assertShow(survey.xpath("name"),"health");
    assertShow(survey.xpath("quiz.questions.name").toString(),"[preference, bibere]");
    assertShow(survey.xpath("quiz.questions.options.id").toString(),"[[1, 2, 3, 99], [1, 2, 3]]");
    assertShow(survey.xpath("quiz.questions[1].options[1..2].id").toString(),"[2, 3]");
    assertShow(survey.xpath("quiz.questions.options[0..1].answer").toString(),"[[Margarita, Regina], [Italian Red wine, Sicilian white wine]]");
  });

  // as models.yaml object is read only, it's often better to transpose in json
  var xJson = json.decode(json.encode(xYaml));
  survey = JsonObject(xJson);

  test("---- test from models.yaml transposed in json ----", (){
    assertShow(survey.xpath("name"),"health");
    assertShow(survey.xpath("quiz.questions.name").toString(),"[preference, bibere]");
    // compare array through string, otherwise see ListEquality().
    assertShow(survey.xpath("quiz.questions.options.id").toString(),"[[1, 2, 3, 99], [1, 2, 3]]");
    assertShow(survey.xpath("quiz.questions[1].options[1..2].id").toString(),"[2, 3]");
    assertShow(survey.xpath("quiz.questions.options[0..1].answer").toString(),"[[Margarita, Regina], [Italian Red wine, Sicilian white wine]]");
  });

}