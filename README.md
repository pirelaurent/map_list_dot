# MapList : quick prototyping
## Create pseudo class with accessors from json descriptor
A json String, a json 'Dart', or any maps & lists set, are enough to create a class with a dot notation to access properties.
```dart
dynamic p1 = MapListMap({
  "name": "Polo",
  "firstName": "marco",
  "birthDate": { "day": 15, "month": 9, "year": 1254 }
});
  print('${p1.firstName} ${p1.name} have now ${DateTime.now().year - p1.birthDate.year} years');
  // -> marco Polo have now 766 years
```
### can use setters
``` dart
p1.firstName = 'Marco';
```
### can dynamically add new data and use new properties
``` dart
// add a collection for business cards 
 p1.cards = [];
// add a new card with a pre-filled map 
  p1.cards.add({
    "mail": "ma.po.lo@china.com",
  });
  // add to this -last added- map a new entry 
  p1.cards.last.phone = "+99 01 02 03 04 05";
  print(p1.cards.last.mail);
  print(p1.cards.last.phone);
  //@see examples for more code 
```

## Share your Data Objects with scripts accessors
What is available in dot notation within Dart is also available by script :
``` dart
 var script = [
    'persons=[]',
    '''persons.add({ "name": "Magellan", "firstName": "Fernando",
      "birthDate": { "day": 15,"month": 3,"year": 1480} 
      })
     ''',
    'persons.last.cards = {"mail": "ma.po.lo@china.com"})',
    'persons.last.cards.phone = "+99 01 02 03 04 05"'
  ];
```
Script executor is under a MapList responsibility
``` dart
 dynamic myKB = MapListMap();
  for (String line in script) myKB.exec(line);
```
Resulting data can be accessed by code or by script
```
print( myKB.persons.last.cards.phone);
print(myKB.exec('persons.last.cards.phone'));
```
# now some details
## constructors
There is two kinds of structures : *MapList***Map** and *MapList***List**  
If you decide by yourself, choose your root within this two options:
``` dart
dynamic myRootMap  = MapListMap();  // empty map { } 
dynamic myRootList = MapListList(); // empty list [ ]
```
If you don't know and must rely on a json :  
use the factory that do the job and returns the right root class.
``` dart
dynamic myRoot = Maplist(someJson);
```
### constructors with json data
Each constructor can be default as above, or can be initialised with :
- a Json String
- an inline maps and lists in dart
- an already loaded 'Dart Json'

``` dart
dynamic myRootMap  = MapListMap('{"name":"Polo"}'); // string 
dynamic myRootMap  = MapListMap({"name":"Polo"});   // inline

var myJson = json.decode('{"name":"Polo"}');  
dynamic myRootMap  = MapListMap(myJson);          // already json dart
```
Same options for **MapListList** constructors, but beginning by a List [ ]  
Same options for Factory **MapList** which will decide of the following.

## accessing data
Classical and dot notation are usable in code and in scripts.  
The result is the last leaf which could be a simple data, a List, a Map or a null if not found.
#### classical notation
``` dart
root["show"]["videos"][1]["name"]
```
#### dot notation
``` dart
root.show.videos[1].name
```
#### General access
a ***.someName*** indicates a key entry in a map.
- if the result is another Map
  - can continue with another key : ***.someName.someList***
- if the result is a List
  - can continue with an index  : ***someList\[1]***
  - can use the keyword ***last*** : ***someList.last***
    - The result of the result can be a Map or another List
      - *someList \[10].anotherKey*
      - *somelist \[10] \[2] *
- if the result is a simple data, cannot continue notation : must be the last leaf.
  - the full name allows to get data : ***someName.someList\[1]***  -> 10;
  - the full name allows to set data : ***someName.someList\[1] = 12***;


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
dynamic squad = MapListMap(); // create an empty map as squad. 
squad.members = [];        // add an empty list named 'members' 
squad.activities = {};     // add also an empty map 'activities' at first level
dynamic squad = MapListMap({members: [], activities: {}); // the same in one line at construction
```

##### create simple data
Any new name at a map level will create the data if they not exist ( and replace them if they exist)
``` dart
dynamic squad = MapListMap();          // will create a default Map
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
   root = MapListMap({"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }});
  // If you plan to use heterogeneous data : better to precise type: 
   root = MapListMap( {"dico":<String,dynamic>{"hello":{"US": "Hi", "FR": "bonjour"} }});
    //  or use json string message that do the job with its internal types:
    root = MapListMap(' {"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }} ');
    
  ```
#### can use relay to simplify access
``` dart
// follow previous sample : create with more complex data 
root.dico.numbers = {"US": ["zero","one","two","three","four","five","sic","seven","eight","nine"]};
var numbers = root.dico.numbers; 
var USnumbers = numbers.US;
print(USnumbers[3]);
```
### add new elements to existing
#### add a MapList into another MapList
``` dart
dynamic car = MapListMap();  // use dynamic to allow dot notation on root
car.brand = "Ford";
car.colors = ["blue","black","white"];
car.chosenColor = "white";
// now add this car to a larger set 
dynamic myStuff = MapListMap();
myStuff.myCar = car;      // create a property myCar with given values 
```
#### Add new elements to an existing List : add & addAll
``` dart
dynamic list = MapListList();  
list.add(15);
list.addAll([1, 2, 3]); 
list.add({"date":"october 16"}); 
print(list); //[15, 1, 2, 3, {date: october 16}]
```
##### add or change elements of a map with another map : addAll
``` dart
dynamic car = MapListMap();
car.name = "ford";
// add to this map several key:value in one shot or change existing
car.addAll({ "name":"Ford","price": 5000, "fuel":"diesel","hybrid":false});
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
### MapLists return null on unknown data
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
 If the list doesn't exist at all, the nullable must be checked **before the index** to avoid error on the operator [ ]:
``` dart
store.pocketBookList?[0].author = "zaza";
```
Dart allows this syntax recently **with Dart 2.9.2**.  
Before 2.9.2 you cannot compile with a nullable before \[0\] in code.  
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
If a type is not indicated, Dart infers the type from the current assignment and ```[11,12,13]``` will be a ```List<int>```.  
From there, you can only add other ```<int>``` without errors, nothing else like "hello" without a crash.  
Similar things can happen with a map.  
This code  will fail :
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
If you use constructors with a String structure, or 'dart json', MapList do the job of enlarging types to dynamic.
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
Leaving dart inline tolerance in script or json : comma at the end \[11,12,]
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
(As a node could be a large thing, toString truncates... the data )
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
When a path ends with an unknown name in a map, the last node is null but not the trip :
``` dart
   print(jsonNode(aJson, 'questions.newData'));// (map){A: AA, B: BB}  --- newData -> (Null) null 
```
A caller, like MapList do, can check the results and set the data with *fromNode\[edge\]* .  
(if the path starts at the very beginning, the fromNode is also null and the edge must be applied to the root )

#### Same Hell of types in interpreter
Same precautions has to be taken on datatypes to avoid bad surprises.  
Writing inline data with types could be cumbersome :  
``` dart
var aJson = <dynamic>[ [1, 2, 3], <String,dynamic> {"A": "AA", "B": "BB"},  "andSoOn" ];  
```
**Tip**: Prefer using a json String and let MapList do a *json.decode(string)*  do the job.
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
The script below returns a simple data :
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
The Left Hand Side of a script with assignment is the path to get by MapList.  
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
#### Weakness
Probably some in the analysis of syntax in interpreter : in case of trouble verify deeply your strings.  
MapList uses Symbol without mirrors and get the symbol name by hand : This could have issues with dart.js minifier, case which has not been tested here.
