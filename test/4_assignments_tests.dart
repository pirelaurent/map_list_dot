import 'package:json_xpath/src/map_list.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;


/*
  if wrong test , show what was expected and what we got
 */
void assertShow(var what, var expected) {
  assert(what == expected,
  "\nexpected: $expected  ${expected.runtimeType} got: $what ${what.runtimeType}");
}


void main() {
dynamic root;
  test("assignments standard and dot notation", () {

// dot notation way
    root.show.name = "quizine";
    assertShow(root.show.name, "quizine");
// more
    root.show.videos[1].questions[1].options[2].answer = "gogol";
    assertShow(root.show.videos[1].questions[1].options[2].answer, "gogol");
// more on List
    assertShow(root.show.videos[1].questions[1].options[2].length, 3);
    assertShow(root.show.videos[1].questions[1].options.length, 5);
    root.show.videos[1].questions[1].options.add({"next": "another"});
    assertShow(root.show.videos[1].questions[1].options.length, 6);
  });

  test(" create data standard and dot notation with relay ", () {
// more on a Map : allow to create new entries
// using a relay
    dynamic q2 = root.show.videos[1].questions[2];
    q2.options[1].bonus = "you win a bonus";
    assertShow(
        root.show.videos[1].questions[2].options[1].bonus, "you win a bonus");
// create a new List in a Map
    root.show.verifications = [];
    root.show.verifications.add({"name": "first"});
    root.show.verifications.add({"name": "second"});
    assertShow(root.show.verifications.length, 2);
    assertShow(root.show.verifications[1].name, "second");
  });

  test("decoded variables in script",(){

    test("creation of data at very beginning", () {
      root.elapsed_time = 33;
      assert(root.elapsed_time == 33);
      assert(root.length ==2);
      root.script('elapsed_time = null');
      assert(root.elapsed_time == null);
    });


  });




}