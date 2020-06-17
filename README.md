# MapList :
## access any json or json-like maps & lists with a dot notation
MapList is a wrapper around any kind of json-compatible data.  
MapList can use dot notation directly in Dart code and offer an interpreter to access data via script.
# part1 : Dot access with Dart code
### Constructors
MapList uses a factory and allows several constructors :
```
 MapList();           // create a first empty node as a Map (default)
 MapList({});         // same as previous. More explicit.
 MapList([])          // create a first empty node as a List 
 MapList(jsonString); // create a full structure with a valid json string
 MapList(someStructure);  // uses an already 'maps & list' structure or a Dart json object
```
Only the first level needs to be a MapList. You can then add directly maps, lists and data , in line or as json.
### Accessing data
In the following  examples, a MapList *root* has been loaded with a json.
#### Classical notation reminder
``` dart
root["show"]["name"]
root["show"]["videos"][1]["name"]
root["show"]["videos"][1]["questions"][1]["options"][2]["answer"]
```
##### Available dot notation
``` dart
root.show.name
root.show.videos[1].name
root.show.videos[1].questions[1].options[2].answer
```
### Creating & setting data
You can create data from scratch, or add and change data to existing in a simple way.
##### Create empty structures
``` dart
dynamic squad = MapList(); // create an empty map as root   
squad.members = [];        // add an empty list 'members' in the squad map
squad.activities = {};     // add an empty map 'activities' in the squad map
print(squad);              // {members: [], activities: {}}   
```
##### Design and fills in  a data object from scratch
Any new name at a map level will create the data if it not exists ( or replace it if exists)
``` dart
dynamic squad = MapList();          // will create a default Map
squad.name = "Super hero squad";    // add a String data 
squad.homeTown = 'Metro City';      // another 
squad.formed = 2016;                // add an int
squad.active = true;                // add a bool
squad.score = 38.5;                 // add a double 
```
##### add all entries of another Map : addAll
``` dart
dynamic car = MapList();
car.name = "Ford";
car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false});
print(car);     //{name: Ford, price: 5000, fuel: diesel, hybrid: false}
```
##### adding elements to a List : add & addAll
``` dart
dynamic list = MapList([]);  
list.add(15);
list.addAll([1, 2, 3]);
print(list);            // [15,1,2,3]);
```
#### adding complex data
Any structure of maps, lists and data can be added
##### Sample: add a new member to a newly created squad with an inline data
``` dart
  dynamic squad = MapList();              // will create a default Map
  squad.members = [];
// add a full structure to the previous  list
  squad.members.add({                     // this new members will be members[0]
    "name": "Molecule Man",             // members[0] is a map with several data
    "age": 29,
    "secretIdentity": "Dan Jukes",
    "powers": ["Radiation resistance", "Turning tiny", "Radiation blast"] // powers is a List at a second level
  });
  // last is the keyword for the last element of a List . Here we can have used powers[2]
  print(squad.members[0].powers.last);    // Radiation blast 
```
### Check nullable while accessing data
To avoid a error **"NoSuchMethodError: The getter 'someData' was called
on null"** while accessing data, MapList takes care of the nullable notation.  
The following code will return null or the data, without throwing error if *wrongName* doesn't exist in the sample
```
store.wrongName?.someData
```
##### Wrong index on a List will return null. Use nullable to protect downstream
```dart
store.book = ["A","B","C"];
store.book[400]?.author = "zaza" ); // will do nothing as book[400] doesn't exist , otherwise got a " Dart error 'author was called on null" 
```
**About checking and errors** : MapList send warning and errors on standard **logging**. (Apps must set an effective logger to see messages).
MapList try to avoid crash and returns null on a getter with message.
```dart
print(store.book[400]);             // -> null;
    // WARNING: unexisting book [400] : null returned .
    // Original message : RangeError (index): Invalid value: Not in range 0..3, inclusive: 4 
store.book[400]?.author = "zaza";    // same message 
   ```
#### Non existing List & Dart restriction on nullable
 if the **List doesn't exists at all**, the nullable must be checked before
 the index to avoid error: *The method '[]' was called on null.*  :
```
assert(store.bookList?[0]==null); // but won't compile before Dart 2.9
```
Dart allows this syntax **only with Dart 2.9** Cannot be used on lower. (as is this work)
## The hell of data types
### principles
**get data** : There is no restriction to get data, as long as the structure is made of maps, lists and simple types.  
As examples, any inline structure, any json or any yaml structure can be accessed with dot notation.  
**set data** : MapList rely on **\<String,dynamic> Maps** and **\<dynamic> Lists**, which are full compatible with json format.
#### problems with Dart inline (or from other sources) structures
If type is not indicated, Dart will derived the type from the current data:  
```[1,2,3,4]``` will be a ```List<int>```. No problem as long as you add other ```<int>``` to this list.  
But if you try to add a *String* or a *Map* in this List, Dart will crash in error.
##### Type the inline for security
``` dart
root.results.add({"elapsed_time": 30, "temperature": 18}) // is ok but with an inferred  Map<String, int>  
root.results[0].time = "12:58:00";        // will fail : type 'String' is not a subtype of type 'int' of 'value'
```
If you plan to have a more open behavior, cast the inline structure :
``` dart
root.results.add( <String,dynamic>{"elapsed_time": 60, "temperature": 40});
root.results[0].time = "12:58:00"; // now ok ! 
```
Same thing to think about with List :
```
root.data = [11, 12, 13];   // will infer a List<int> 
root.data.add(14);          // ok
root.data.add("hello");     // will fail :type 'String' is not a subtype of type 'int'
```
Adding type is more secure on future data :
```
root.data = <dynamic>[11, 12, 13];
root.data.add("hello");   // ok 
```
**More samples in unit tests**
### Json alignment
Standard Dart json uses **Map\<dynamic,dynamic>** and **List\<dynamic>**  
if you load data from a standard json (from a file or from a message ) everything will be ok.  
MapList uses **Map\<String,dynamic>** as it's mandatory to get data with a printable String name.  
This is full compliant with standard json, except fo the *addAll* method on Maps:  
Dart checks that both Maps have very exactly the same type, and Dart rejects an addAll between a <String,dynamic>Map and a <dynamic,dynamic> Map:  
=> This is why MapList overrides *addAll* to loop on discrete elements.

### Logged errors
MapList try to avoid runtime errors.  
If something is wrong, it does'nt throw errors but logs Warning and continue.  
On a wrong get, it returns null and on a wrong set : do nothing .  
Think about instantiate a real log listener in your code to see these warnings.
#### most common warning :
Use Map as List or List as Map
```dart
name["toto"]="riri"     WARNING: index ["toto"] must be applied to a map. no action done.   
name[0]="lulu": [0]     WARNING:  [0] must be applied to a List. no action done.
print(root.price);      WARNING:  ** Naming error: trying to get a key "price" in a List. null returned    
```
Wrong index in List
```dart
print(root[200]);       WARNING:  unknown accessor: . [200] : null returned .(followed by original dart error 'Not in range..') 
```
Wrong json data if given as a String at runtime (if inline code, compiler will warn )
``` dart
dynamic root = MapList('{"this": is not a[12] valid entry }'); ** wrong json data. null returned .(followed by original conversion error) 
```
##### Remaining runtime errors
Types errors if inline data are not correctly casted as explained previously.  
My favorite is about using Yaml structure that fails only when trying to change a value:
``` dart
var yamlStructure = loadYaml(yamlString);
dynamic root = MapList(yamlStructure);
root.show.name = "new video title";
-> 'runtime Error: Unsupported operation: Cannot modify an unmodifiable Map';
```
#### tips for Yaml
The most simple to get a writable json from a read-only yaml is to do :
``` dart
root = MapList(json.decode(json.encode(yamlStructure)));
```
---------------------------------------------------------------------
---
# part 2 : MapList Interpreter
This work is a first step with a wider interpreter in mind.  
This part allows to get and set data by script which can be useful working with text messages.
Any MapList can be accessed by code or by script in the same manner.
## constructors
All the MapList constructors can be used; The most useful, for example on a received message in string, is the following.
```
MapList(jsonString); // create any structure with a valid json string
 ```
### Accessing data : get, set, exec
set, get and exec indicate the catagory of action to execute :  
- **get** is designed to **get** a leaf data or a pointer to an intermediate node with some special terms :
  - .length
  - .last
  - .isEmpty
  - .isNotEmpty
- **set** is designed to **create** a data or a structure and to **replace** it if it exists.
- **exec** is reserved for action on data :
  - .clear()
  - .add(something)
  - .addAll(several something)
  - .remove(something)
#### Warnings
To show mismatch use of a verb, MapList logs the following :
```dart
root.set('scores'); // WARNING : Calling set without = : Be sure it's not a get or an exec .no action done 
// must be: root.get('scores'); 
root.set('clear()');    // WARNING : Calling set without = : Be sure it's not a get or an exec .no action done  
// must be: root.exec('clear()');
root.get('video.name = "Max"'); // WARNING : calling get with an equal sign. Be sure it's not a set . null returned 
// must be: root.set('video.name = "Max"')
root.exec('clear'); // WARNING cannot search a key (clear) in a List<dynamic> 
// must be: root.exec('clear()');
```
### get data
Every notation (classical or dot notation ) is allowed in a script.  
Assuming *root* is a MapList already loaded, you can get data named by a script as follow :
```dart
root.get('["show"]["videos"][1]["questions"][1]["name"]') // classical notation 
root.get("show.videos[1].questions[1].options[2].answer") // dot notation  (preferred)
root.get('show["videos"][1].questions[1]["options"][2].name') // even a mix is allowed  
```
#### set
The syntax is  ***set('path = data')***  
As data arrive in a text format , MapList recognize the following and convert it in the right type:

| Type                | samples                                                                                  |
|:--------------------|:-----------------------------------------------------------------------------------------|
| string              | ```"hello", 'hello'```        with the other string wrapper than one at exec( ) level. |
| bool                | ```true, false    ```                                                                    |
| int                 | ```15 , -1 , 0   ```                                                                     |
| double              | ``` 2.899, -0.125 ```    (more generally what react ok to num.tryParse                   |
| map                 | ``` { }   ```                                                                            |
| list                | ```[ ] ```                                                                               |
| any valid structure | ```{"name":"toto", "score": [11,15,8]} ```                                               |

#### Samples on a map

```
dynamic squad = MapList();
squad.set('name = "Super hero squad"'); // String with '" "'
squad.set("homeTown = 'Metro City'");   // String with "' '"
squad.set('formed = 2016');             // int
squad.set('active = true');             // bool
squad.set('score = 38.5');              // double 
```
### Creating and setting maps or lists
#### empty structures
```
dynamic squad = MapList();
squad.set('name = "Super hero squad"'); // String entry
squad.set('members = []');              // Empty list names members 
```
##### addAll to a Map
Another syntax allowed for set is the reserved word *addAll*.

```
dynamic car = MapList();
car.set('name = "Ford"');
car.set('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})');
car.exec('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})'); // set is just a front on exec which is available too. 
```
##### add & addAll to a List
```
dynamic list = MapList([]);  
list.set('add(15))';
list.set('addAll([1, 2, 3]');
```

#### set larger structures
( Dart format string on several lines with several ' ' )
```
squad.set('members = []');
squad.set(
    'members.add({ "name": "Molecule Man","age": 29,"secretIdentity": "Dan Jukes",'
    '"powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]})');
```
## Nullable capacities
Interpreter takes care of nullable notations at all levels  :

```
store.get('wrongName?.someData')
store.get("book[4]?.author
store.get("bookList?[0]")
store.get("bookList?[0]?.date")
```
#### Caution : special interpreted name : *length*
MapList takes care of the *.length* item as it could be a valid entry in a
map or a question about the physical length of the map or the list.  
**MapList always return the length of a List or a Map on .length**
If some data is named length in a data set, it can be reached only with the standard notation :
```
// {"category": "road", "model": "Propel advanced Disc ", "color": "grey",  "price": 2900, "length": 2.20 }
assert(store.get('bikes[1].length')== 5);       // size of the map bikes[1] 
assert(store.get ('bikes[1]["length"]')== 2.2); // property length of bikes[1]
 ```
(free advice : avoid to name a property 'length'. Here we can have choosen 'lengthOfBike')

---
  # A look inside
  ## classes
   **MapList** is a wrapper class around a unique *json*.  
   **MapListList** and **MapListMap** are two derived classes to take care of specific access.
#### about keyword *is*
A MapList cannot be checked by *'is Map'* or *'is List'*, but by **'is MapListMap'** or **'is MapListList'**  
*( one can always check (myPosition.json is Map) or (myPosition.json is List))*  
An attempt was made with *ListMixin* and *MapMixin* respectively on MapListList and MapListMap, but this leaves unresolved conflicts due to same inheritance from MapList.

```
root = MapList({"members": [ { "name": "Bourne", "age": 33 }]});
assert(root is MapList);
assert(root is MapListMap);
assert(root.members is MapList);
assert(root.members is MapListList);
assert(root.members[0] is MapListMap);
assert(root.members[0].name is String);
```
### How dot notation works in Dart
#### noSuchMethod on a MapList to access data
MapList is dynamic and use **dart:mirrors**  to use and override the  **noSuchMethod**  
When a dot notation is compiled by Dart, Dart will call individuals parts and use the result for the next call :
```
root.a.b.c[2].d = 33 
```
1-Dart calls *noSuchMethod ('a')* to the MapList root.  
2-MapList *returns a new MapList*( a MapListMap ) with a shifted json inside ( not a copy, on the same pointers)  
3- Dart calls *noSuchMethod ('b')* on the returned MapList, which returns a new MapList (a MapListMap) shifted on b as first entry.  
4- Dart calls *noSuchMethod ('c')* on the returned MapList, which returns a new MapList (a MapListList) shifted on c as first entry.  
5-Dart calls *operator \[1]* on the received MapList that chains to the \[1\] operator on the internal MapListList, which returns again a shifted MapList  
6-Dart calls  *noSucheMethod (' d=', 33)* to the MapListMap that apply the assignement and return nothing.

###### how dot notation works in interpreter
The access in interpreted don't use the noSuchMethod of MapList, but progress internally on the current structure.
```
root.exec("a.b.c[2].d["price"] = 33");
```
The received String is split around the. and analyse each part :
1-a
2-b
3-c\[2] : when brackets are found, a second internal loop runs to solve indices : find c, try a c[2]
4-d\["price"] : for tutorial sample (better to use b.price ) : when brackets are found, they are applied once the dry name solved : d, then price key.  
5- = 33 : apply the value.

### odds & ends
 **some utility methods**
  The following are available directly on MapList in **Dart code** and relay on internal map or list methods
```
bool .isEmpty     // maps or lists 
booo .isNotEmpty  // maps or lists 
bool .hasKey()    // maps 
```
The previous methods are not available in interpreter as it allows only get or set (not if )  
*.clear* is also available in code and can be simulate in interpreter by a *.set({})* or a *.set([]) *





 ** caution on path name **
The left path is the same in code or interpreter, without quotes :
```
book.name = "zaza"
book.set('name = "zaza"');
```
If you over quote a path , you are able to create another entry :
```
book.set('"name"="zorro"');
-> {name: zaza, "name": zorro }
```

**can use any MapList relay on the way**
As a dotted question returns a MapList at every level, (and as the json entries are never copied but stay as pointers) One can use intermediate dynamic for commodity:
```
 dynamic root = MapList(jsonString);  
 dynamic store = root.store;
 dynamic bookCollection = store.book;
 dynamic myPrefered = bookCollection[2];
```

### some idea
You can use a first level map to store all your different MapLists by name as a variable container:
``
dynamic blackboard = MapList({});
blackboard.store = MapList(.....);
blackboard.news = MapList(.....)':
blackboard.heroes = MapList(.....):
``
Every query on data can rely on the unique blackboard entry point, which is more general in interpreter :
```
print(blackboard.get('store.book[1].isbn'));
if (blackboard.get('squad.members[2].powers.Radiation resistance) != null)...
```

####  Further work
The interpreter is reduced to getter and setter on stuctured data .  
A further work is to extend it to a larger usage.
