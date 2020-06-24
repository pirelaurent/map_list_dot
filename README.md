# MapList :
## access json (or any maps & lists) with a dot notation
MapList is a wrapper that offers dot notation to be used in Dart code.  
As a complement Maplist allows to get and set data with textual scripts using an interpreter.

#### sample of use in dart code and with interpreter
``` dart
  if (root.videos[1].questions[2].options[1].answer == "white") print('you win'); 
  // in some listening code 
  onMessage (String message ) { root.exec(message) };
  // from some sender 
  sendMessage('videos[1].questions[2].options.add({"code":"B4","answer":"purple"})')
```

### how to
- create a MapList (see constructors)
  - ```MapList root = MapList(someStructure);```
- navigate in dot notation , even on a long path :
  - ```print(root.show.videos[1].questions[2].options[1].answer);```
### Constructors
MapList uses a factory and allows several constructors :
```
 MapList();             // create a first empty node as a Map (default)
 MapList({});           // same as previous. More explicit.
 MapList([])            // create a first empty node as a List 
 MapList(jsonString);   // create a full structure with a valid json string
 MapList(someStructure);  // uses an already 'maps & list' structure or a Dart json object
```
### several notations allowed
Classical and dot notation are allowed. You can even mix them as a bad idea.  
The result is the last leaf which could be a simple data, a List, a Map or a null if not found.
#### classical
``` dart
root["show"]["name"]
root["show"]["videos"][1]["name"]
root["show"]["videos"][1]["questions"][1]["options"][2]["answer"]
```
#### dot notation
Depending of the last leaf, will return a data or a pointer to the sub-structure
``` dart
root.show.name
root.show.videos
root.show.videos[1].name
root.show.videos[1].questions
root.show.videos[1].questions[2].options
root.show.videos[1].questions[2].options[1].answer
```
#### dumb mixed notation
``` dart
root["show"].videos[1]["questions"][2].options[1].answer
```
#### Following special words are get or set from/to the wrapped json:
``` dart
// on Lists
root.show.videos.length 
root.show.videos.clear()
root.show.videos.isEmpty   // or isNotEmpty
root.show.videos.last
// on Maps
root.show.length
root.show.clear()
root.show.isEmpty   // or isNotEmpty
```
### create and set data with dot notation
##### create empty structures
``` dart
dynamic squad = MapList(); // create an empty map as squad. Default is a map   
squad.members = [];        // add an empty list named 'members' 
squad.activities = {};     // add also an empty map 'activities' at first level
print(squad);              // {members: [], activities: {}}   
```
Note : it is not possible to create unknown data on several levels in one call : *squad.person.name = "zaza"*  
( an unknown is created only when there is an assignment. Previous could be done by *squad.person ={"name":"zaza"}*
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
##### create with more complex data
  ``` dart
  // creation with direct structure  
   root = MapList({"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }});
  // but as we plan to use heterogeneous data at the dico level , better to do : 
   root = MapList( {"dico":<String,dynamic>{"hello":{"US": "Hi", "FR": "bonjour"} }});
   root.dico.numbers = {"US": ["one","two","three","four","five","sic","seven","eight","nine"]};
 // More easy: using a json string message , MapList will create correct types.
    root = MapList(' {"dico":{"hello":{"US": "Hi", "FR": "bonjour"} }} ');
    root.dico.numbers = {"US": ["zero","one","two","three","four","five","sic","seven","eight","nine"]};
  ```

#### use relay to simplify access
``` dart
// follow previous sample : create with more complex data 
var numbers = root.dico.numbers; 
var USnumbers = numbers.US;
print(USnumbers[3]);
```
### add new elements
#### add MapList to MapList
``` dart
dynamic car = MapList();  // use dynamic to allow dot notation on root
car.brand = "Ford";
car.colors = ["blue","black","white"];
car.chosenColor = ["white"];
// now reuse it to add it in a new structure
dynamic myStuff = MapList();
myStuff.myCar = car;
```
Adding new elements to an existing List : add & addAll
``` dart
dynamic list = MapList([]);  
list.add(15);
list.addAll([1, 2, 3]); 
list.add({"date":"october 16"}); 
print(list); //[15, 1, 2, 3, {date: october 16}]
```
##### add elements of a map to an existing one with addAll
``` dart
dynamic car = MapList();
car.name = "Ford";
// add to this map several key:value in one shot
car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false});
```


### The hell of data types and how to protect code
MapList presupposes  **Map\<String,dynamic>**  and **List\<dynamic>** to work well.  
Using and adding json data (which are *Map\<dynamic,dynamic>* and *List\<dynamic>*) is full compliant.
#### warn with inline coded structure
If a type is not indicated, Dart infers the type from the current assignment:  
```[1,2,3,4]``` will be a ```List<int>```.  
From there, you can only add other ```<int>``` without errors, nothing else without a crash.  
As this is designed as an open world of data like json, don't stay restricted.
#### think about adding Types to the inline structures
This code with a List will fail:
```
root.data = [11, 12, 13];   // will infer a List<int> 
root.data.add(14);          // ok
root.data.add("hello");     // will fail :type 'String' is not a subtype of type 'int'
```
This one with a List will not fail:
```
root.data = <dynamic> [11, 12, 13];   // will impose List<dynamic>
root.data.add(14);          // ok
root.data.add("hello");     // ok
```
This code with a mal will fails:
``` dart
root.results = {"elapsed_time": 30, "temperature": 18} // is ok but result is a List of Map<String, int>  
root.results.time = "12:58:00";        // will fail : type 'String' ("12:58:00") is not a subtype of type 'int' of 'value'
```
This code will not fail :
``` dart
root.results =  <String,dynamic>{"elapsed_time": 60, "temperature": 40};
root.results.time = "12:58:00"; // now ok ! 
```
*More samples on github in unit tests*
### Check nullable while accessing data
```
store.wrongName.someData
```
To avoid the error **"NoSuchMethodError: The getter 'someData' was called on null"**, Dart takes care of the nullable notation.  
The following code will return null or the data, without throwing error.  
```
store.wrongName?.someData
```
##### Wrong index on a List will return null.
MapList trap the index errors and returns null in place of a non existing data.  
MapList logs also a reminder of the initial error on a standard logging :
```dart
print(store.book[400]);  //-> null 
    // WARNING: unexisting book [400] : null returned .
    // Original message : RangeError (index): Invalid value: Not in range 0..3, inclusive: 4 
```
As first part returns null, you can protect downstream with a nullable option :
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
dynamic root = MapList('{"this": is not a[12] valid entry }'); 
**WARNING** wrong json data. null returned .
(followed by original conversion error) 
```
##### remaining runtime that can throw errors
If inline data are not correctly casted as explained previously, you can get runtime errors.  
My main oversight is about using Yaml package as is. Getters are ok but setters will fail :
``` dart
var yamlStructure = loadYaml(yamlString);
dynamic root = MapList(yamlStructure);
root.show.name = "new video title";
-> 'runtime Error: Unsupported operation: Cannot modify an unmodifiable Map';
```
#### tips for Yaml
The most simple way to transform a read-only yaml in a full compliant json is the following :
``` dart
root = MapList(json.decode(json.encode(yamlStructure)));
```
### some more useful details
A MapList has a *.json* accessor to get the wrapped one if necessary.  
MapList works with pointers, not copies :  
  json data can stay synchronised between direct access to json, use with MapList in code, or use of MapList interpreter.
( More technical details in Readme_more.md on github. )


---
---
# MapList access interpreter
An interpreter have some well known use cases :
- applying create or update messages on a data set
- free interaction with data not known at compile time
- use maps and lists as an open graph
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
Below is shown the internal structure. To just keep the result, call:  
*jsonNode(json,path)**.value***   like in :  
``` assert(jsonNode(aJson, '[2].B').value == "BB");```
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
#### special words
JsonNode get data and some properties:
- .length
- .isEmpty
- .isNotEmpty
- .last  (on Lists )
- .clear()
- .last
#### creation of unknown data
When a path ends with a name that has not been created, the last node is null :
``` dart
   print(jsonNode(aJson, '[2].newData'));// (map){A: AA, B: BB}  --- newData -> (Null) null 
```
As the caller get the fromNode and the edge, it can create the data. That is what **MapList** do.  
(If the path stays at the very beginning, the fromNode is also null and the edge must be applied to the root )
#### The Hell of types

Same precautions has to be taken on datatypes to avoid surprises.  
The first sample will be more sure with (supposing internal subLists stays as int ) :  
```var aJson = <dynamic>[ [1, 2, 3], [11, 12], <String,dynamic> {"A": "AA", "B": "BB"},  "andSoOn" ];```
Or to be sure that everything is dynamic , and more accurate for an interpreter, use a string :  
```var aJson = json.decode('[ [1, 2, 3], [11, 12],  {"A": "AA", "B": "BB"},  "andSoOn" ]');```
That's what **MapList** do when a string is used.


## now the MapList interpreter itself
### exec(script) method
When you have a MapList you can call the exec method with a text script.
#### get data
The script could be a simple getter to obtain a data ( query delegated to a JsonNode ) :
``` dart
    dynamic book = MapList();
    book.exec('addAll({ "name":"zaza", "friends": [{"name": "lulu" }]})');
    print(book.exec('friends[0].name')); // -->  lulu);
 ```
Tip : don't strike a complex json directly between quotes : use dart to create the structure or the function , then put in in a string.

#### notation to get data
You can use same notation than in code to access a data.  
Remember that in interpreter the root is the executor and is not repeated in the path :

``` dart
dynamic root = MapList(myJson);  
root.show.videos  // in code 
root.exec('show.videos'); // in interpreter
```
MapList will return directly the data.  
For an end leaf, it returns the value,  
for an intermediary node, it returns the json wrapped in a new MapList, either MapListList or MapListMap to allow continuation of dot notation in code.

#### notation styles
```root.exec('["show"]["videos"][1]["questions"][1]["name"]') // classical notation```  
```root.exec('show.videos[1].questions[1].options[2].answer') // dot notation ```

```dart
store.exec('bikes[1].length'); // size of the map bikes[1] 
store.exec ('bikes[1]["length"]'); // property length of the bike in bikes[1]
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
#### methods that set data without assignment

#### special  words to create or update data
- clear()   *clear the named location, map or list*
- add(something)  *Only for Lists : add a new element*
- addAll(several something)  *Add all elements of a map to a map or all elements of a list to a list.*
- remove(something)   *Remove an entry of a map or an element in a list*
- length = \<int>  *Force the length of a List*


**last** keyword can be used on Lists and combined with methods:
```dart
// changing last element 
root.exec('contacts.last = {"name" : "polo", "firstName" : "marco"}'); 
root.exec('contacts.last.addAll("mail" : "marco.polo@silkRoad.com"}');
```

### errors and logs
See the errors and logs in the part1 about code as they are the same in interpreter.  
As syntax errors will arrive late in the interpreter, some more errors can happen like missing parenthesis around functions.
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
Probably some weakness in the analysis of syntax in interpreter : in case of trouble verify deeply your string.  
( as an example, i found late that a missing right parenthesis in a addAll do nothing at all. It's now fixed with a log warning).  
Main crash are on types. Review the chapters.  