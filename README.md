# MapList :
## access json (or any maps & lists) with a dot notation
MapList is a wrapper that offers dot notation to be used in Dart code.  
As a complement Maplist allows to get and set data with interpreted text scripts.

#### sample of use in dart code and with interpreter
``` dart
  if (quiz.questions[2].options[1].answer == "white") print('you win'); 
  // with interpreter 
  sendMessage('questions[2].options.add({"code":"B4","answer":"purple"})')
  onMessage (String message ) { quiz.exec(message) };
```

### how to
- create a MapList (see constructors)
  - ```MapList root = MapList(someStructure);```
- use dot notation , with full path :
  - ``` print(root.videos[1].quiz.questions[2].options[1].answer); ```
- or with relays:
  - ```MapList quizBurger = root.videos[1].quiz.questions[2];```  
        ``` print(quizBurger.options); ```
### Constructors
MapList uses a dynamic factory and allows several constructors :
``` dart
 MapList();             // create a first empty node as a Map (default)
 MapList({});           // same as previous. More explicit.
 MapList([])            // create a first empty node as a List 
 MapList(jsonString);   // create a full structure with a valid json string
 MapList(someStructure);// uses an already 'maps & lists' set or a json
```
### several notations allowed
Classical and dot notation are allowed.  
The result is the last leaf which could be a simple data, a List, a Map or a null if not found.
#### classical notation
Available, but no more than without MapList.
``` dart
root["show"]["name"]
root["show"]["videos"][1]["name"]
root["show"]["videos"][1]["questions"][1]["options"][2]["answer"]
```
#### dot notation

``` dart
root.show.name
root.show.videos
root.show.videos[1].name
root.show.videos[1].questions
root.show.videos[1].questions[1].options
root.show.videos[1].questions[1].options[2].answer
```
#### dumb mixed notation
``` dart
root["show"].videos[1]["questions"][1].options[2].answer
```
### special words
Some words are identified as questions or actions.
``` dart
// on Lists
root.show.videos.length 
root.show.videos.clear()
root.show.videos.isEmpty  
root.show.videos.isNotEmpty 
root.show.videos.last
// on Maps
root.show.length
root.show.clear()
root.show.isEmpty   
root.show.isNotEmpty   
```
### create and set data with dot notation
##### create empty structures
``` dart
dynamic squad = MapList(); // create an empty map as squad. Default is a map   
squad.members = [];        // add an empty list named 'members' 
squad.activities = {};     // add also an empty map 'activities' at first level
print(squad);              // {members: [], activities: {}}   
```

##### create simple data
Any new name at a map level will create the data if it not exists ( and replace it if it exists)
``` dart
dynamic squad = MapList();          // will create a default Map
squad.name = "Super hero squad";    // add a String data 
squad.homeTown = 'Metro City';      // another 
squad.formed = 2016;                // add an int
squad.active = true;                // add a bool
squad.score = 38.5;                 // add a double 
```
Note : With dot notation, create unknown data one level at a time (or use json).
##### create with more complex data
  ``` dart
  // creation with direct structure  
   root = MapList({"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }});
  // If you plan to use heterogeneous data :
    //  better to precise type: 
   root = MapList( {"dico":<String,dynamic>{"hello":{"US": "Hi", "FR": "bonjour"} }});
    //  or use json string message that do the job with internal types:
    root = MapList(' {"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }} ');
    
  ```
#### use relay to simplify access
``` dart
// follow previous sample : create with more complex data 
root.dico.numbers = {"US": ["zero","one","two","three","four","five","sic","seven","eight","nine"]};
var numbers = root.dico.numbers; 
var USnumbers = numbers.US;
print(USnumbers[3]);
```
### add new elements to existing
#### add a MapList object into another MapList
``` dart
dynamic car = MapList();  // use dynamic to allow dot notation on root
car.brand = "Ford";
car.colors = ["blue","black","white"];
car.chosenColor = ["white"];
// now add this car to a larger set 
dynamic myStuff = MapList();
myStuff.myCar = car;
```
#### Add new elements to an existing List : add & addAll
``` dart
dynamic list = MapList([]);  
list.add(15);
list.addAll([1, 2, 3]); 
list.add({"date":"october 16"}); 
print(list); //[15, 1, 2, 3, {date: october 16}]
```
##### add or change elements of a map with another map : addAll
``` dart
dynamic car = MapList();
car.name = "Ford";
// add to this map several key:value in one shot
car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false});
```
#### Check nullable while accessing data
```
store.wrongName.someData
```
To avoid the error **"NoSuchMethodError: The getter 'someData' was called on null"**,  
Dart takes care of the nullable notation.  
The following code will return null or the data, without throwing error.
```
store.wrongName?.someData
```
note: The interpreter takes care of the null notation.
### MapList returns null on unknown data
- unknown key in a Map
- wrong index on a List
- misused of types , like indexing a Map or using key on a List
- for interpreter :
  - wrong syntax
  - malformed json  

In all cases, MapList will returns null and logs a Warning on the standard logger.

##### Wrong index on a List : sample of log
MapList logs a Warning with a reminder of the initial error :
```dart
print(store.book[400]);  // -> null 
    // WARNING: unexisting book [400] : null returned .
    // Original message : RangeError (index): Invalid value: Not in range 0..3, inclusive: 4 
```
You can protect downstream errors with a nullable option :
```dart
store.book[400]?.author = "zaza" ;  
```
#### Non existing List
 if the list doesn't exist at all, the nullable must be checked **before the index** to avoid error on operator [ ]:
``` dart
store.pocketBookList?[0].author = "zaza";
```
Dart allows this syntax recently **with Dart 9.2**.  
Before 9.2 you cannot compile with a nullable before \[0\] in code.  
The interpreter already allows this syntax.

### The hell of data types and how to protect code
MapList works on a basis of **Map\<String,dynamic>**  and **List\<dynamic>** .  
Using and adding json data, which are *Map\<dynamic,dynamic>* and *List\<dynamic>*, is full compliant.
#### warn with inline coded structure
This codes with a List will fail:
```
root.data = [11, 12, 13];   // will infer a List<int> 
root.data.add(14);          // ok
root.data.add("hello");     // will fail :type 'String' is not a subtype of type 'int'
```
If a type is not indicated, Dart infers the type from the current assignment:```[11,12,13]``` will be a ```List<int>```.  
From there, you can only add other ```<int>``` without errors, nothing else like "hello" without a crash.  
Similar things can happen with a map. This code  will fail :
``` dart
root.results = {"elapsed_time": 30, "temperature": 18} // is ok but result is a List of Map<String, int>  
root.results.time = "12:58:00";        // will fail : type 'String' ("12:58:00") is not a subtype of type 'int' of 'value'
```
#### add \<dynamic\>
Think about adding type <dynamic> to the inline structures :
These new codes will not fail:
```
root.data = <dynamic> [11, 12, 13];  
root.data.add(14);          // ok
root.data.add("hello");     // ok
```
``` dart
root.results =  <String,dynamic>{"elapsed_time": 60, "temperature": 40};
root.results.time = "12:58:00"; // now ok ! 
```
### Logged errors
MapList try to avoid runtime errors:  
If something is wrong, it logs Warning but continue without errors:
- On a wrong get, it logs message and  returns null .
- On a wrong set : it logs message and do nothing else .  
(To see the messages, you must set a logging listener in your code (@see standard logging package).)
#### common warning : using List as Map or Map as List
```dart
 aList["toto"]="riri";
**WARNING** index ["toto"] must be applied to a map. no action done.
```
``` dart
aMap[0]="lulu": 
**WARNING**  [0] must be applied to a List. no action done.
```
```
print(aList.price);      
**WARNING** Naming error: trying to get a key "price" in a List. null returned    
```
Wrong index in List
```dart
print(root[200]);       
**WARNING**:  unknown accessor: . [200] : null returned .(followed by original dart error 'Not in range..') 
```
Wrong json data in a String at runtime (if direct inline code, compiler will warn )
``` dart
dynamic root = MapList('{"this": is not a valid entry }'); 
**WARNING** wrong json data. null returned .
(followed by original conversion error) 
```
##### remaining runtime that can throw errors
Mainly Type mismatch if inline data are not correctly casted .  
Forgotten nullable in the evaluated path.
#### some words about Yaml
I do prefer coding in yaml rather in json, but this have some defaults :
``` dart
var yamlStructure = loadYaml(yamlString);
dynamic root = MapList(yamlStructure);
print(root.show.name);  // ok 
root.show.name = "new video title";
-> 'runtime Error: Unsupported operation: Cannot modify an unmodifiable Map';
```
If all get can work, no set are allowed because the standards yamlMap and yamlList are read only.
#### tips for Yaml
The most simple way to transform a read-only yaml in a full compliant json is the following :
``` dart
root = MapList(json.decode(json.encode(yamlStructure)));
```
### Last details
A MapList has a *.json* accessor to get the wrapped one if necessary.  
MapList works with pointers, not copies :  
  json data stay synchronised between :
- direct access to json
- use with MapList in code
- or use of MapList interpreter.
( More technical details in Readme_more.md on github. )


---
---
# MapList access interpreter
An interpreter have some well known use cases :
- applying create or update messages on a data set
- free interaction with data not known at compile time
- using maps and lists as an open graph
## underlying base : jsonNode
You don't really need to use jsonNode as such, but MapList uses it to walk the graph.  
JsonNode is a kind of canoe that navigates on the data graph with :
- fromNode
- edge
- toNode
- (ascript : the path or the remaining path)

When you create a JsonNode with a path, it returns the last step of its journey.  
The toString returns **(type) fromNode -- last edge in use---> (type) toNode**  
(As a node could be a large thing, toString truncate... the data )
#### returning a data leaf
Below is shown the internal structure to see internal data.
``` dart
var aJson = [ [1, 2, 3], [11, 12],  {"A": "AA", "B": "BB"},  "andSoOn" ];
print(jsonNode(aJson, '[0][1]')); // (list)[1, 2, 3]  --- 1 -> (int) 2
print(jsonNode(aJson, '[2]["B"]')); // (map){A: AA, B: BB}  --- B -> (String) BB  
print(jsonNode(aJson, '[2].length')); // (map){A: AA, B: BB}  --- length -> (int) 2  
```
#### returning a tree branch
``` dart
var aJson = [ [1, 2, 3], [11, 12],  {"A": "AA", "B": "BB"},  "andSoOn" ];
print(jsonNode(aJson,'[0]')); // (list)[[1, 2, 3], [11...  --- 0 -> (list) [1, 2, 3]  
print(jsonNode(aJson,'[2]')); //(list)[[1, 2, 3], [11...  --- 2 -> (map) {A: AA, B: BB} 
```
If you plan to use directly JsonNode, you can get the data by **.value**  
(which is a convenient name to get the last toNode )  
``` assert(jsonNode(aJson, '[2].B').value == "BB");```

#### special words
JsonNode recognize some keywords:
- .length
- .isEmpty
- .isNotEmpty
- .last  (on Lists )
- .clear()

Note about length  
Always use *.length* to get the length of a List or a Map. If there is a key length in a map, you can reach it with notation *\["length"\]*  
``` dart
   dynamic store = MapList('{"bikes":[{"name":"Fonlupt", "length":2.1, "color" : "green" }]}');
   assert(store.exec('bikes[0].length') == 3);
   assert(store.exec('bikes[0]["length"]')== 2.1);
```
#### how a caller can create unknown new data
When a path ends with an unknown name in a map, the last node is null :
``` dart
   print(jsonNode(aJson, 'questions.newData'));// (map){A: AA, B: BB}  --- newData -> (Null) null 
```
A caller, like MapList do, can check the results and set the data with *fromNode\[edge\]* .  
(If the path starts at the very beginning, the fromNode is also null and the edge must be applied to the root )

#### Same Hell of types in interpreter
Same precautions has to be taken on datatype to avoid bad surprises.  
Writing inline data with types could be cumbersome :  
```var aJson = <dynamic>[ [1, 2, 3], <String,dynamic> {"A": "AA", "B": "BB"},  "andSoOn" ];```  
Tip: Prefer using a json String and let MapList (or a *json.decode(string)* ) do the job.
- type in your inline structure to see its correctness : ```[ [1, 2, 3], {"A": "AA", "B": "BB"},  "andSoOn" ]```
- wrap it in quotes : ```'[ [1, 2, 3], {"A": "AA", "B": "BB"},  "andSoOn" ]'```
- use it in MapList(someString)

## MapList *exec(script)* method : get and set data by script
MapList uses underline the previous JsonNode mechanism, get the value and allows to create and set data.
#### get data
You can use same notations than in code to access a data, classical or dot notation.  
MapList will return directly the data:
- for an end leaf, it returns the value,
- for an intermediary node, it returns the json wrapped in a new MapList (returning a MapList allows to combine interpreter and direct code with dot notation in code.)

Notice that the root is the executor and is not repeated in the path :  
below the script returns a simple data :
``` dart
    dynamic book = MapList('{ "name":"zaza", "friends": [{"name": "lulu" }]}');
    print(book.exec('friends[0].name')); // -->  lulu);
 ```
All notation styles are allowed :
```root.exec('["show"]["videos"][1]["questions"][1]["name"]') // classical notation```  
```root.exec('show.videos[1].questions[1].options[2].answer') // dot notation ```
Special word returns also direct values:
```dart
if (store.exec('store.bikes.isEmpty')) print ('what a disaster');
 ```

### scripts to set data
#### assignment with equal symbol
MapList interpreter takes care of an assignment in the script.  
The Left Hand Side of a script with assignment is get by MapList using path.  
The Right Hand Side is evaluated as a simple type data or as a json structure.
``` dart
    dynamic squad = MapList();          // will create a default Map
    squad.exec('name = "Super hero squad"');    // add a String data
    squad.exec('homeTown = "Metro City"');      // another
    squad.exec('formed = 2016');                // add an int
    squad.exec('active = true');                // add a bool
    squad.exec('score = 38.5');                 // add a double
    squad.exec('overhauls = ["2008/04/10", "2102/05/01", "2016/04/17"]'); // add structured data 
```

#### special functions to create or update data
- add(something)
  - Only for Lists : add a new element
- addAll(several something)
  - add all elements of a map to a map
  - all elements of a list to a list.
- remove(something)
  - Remove an entry of a map
  - Remove an element in a list
- length = \<int>
  - force the length of a List

### errors and logs
See the previous chapter on errors and logs for common access errors.  
Some errors normally detected by compiler can happen in interpreted string.  
As an example below is a missing parenthesis around functions.
```dart
root.exec('clear'); // WARNING cannot search a key (clear) in a List<dynamic> 
root.exec('clear()'); // ok 
 ```
### Nullable capacities
Interpreter takes care of nullable notations at all levels  :
```
store.exec('wrongName?.someData')
store.exec("book[4]?.author
store.exec("bookList?[0]")   // Even if Dart is not in 9.2, the interpreter allows this nullable.    
store.exec("bookList?[0]?.date")
```
#### what else
Probably some weakness in the analysis of syntax in interpreter : in case of trouble verify deeply your strings.  
( I found late that a missing right parenthesis in a addAll do nothing at all. It's now fixed with a log warning).