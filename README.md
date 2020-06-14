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
### Accessing data
#### Sample of classical and dot notation in code ( where root is some MapList )
##### classical notation
```
// root has been loaded with a maps and lists structure 
root["show"]["name"]
root["show"]["videos"][1]["name"]
root["show"]["videos"][1]["questions"][1]["options"][2]["answer"]
```
##### dot notation
```
root.show.name, "quiz on video");
root.show.videos[1].name
root.show.videos[1].questions[1].options[2].answer
```

### Creating & setting data

#### in a map
Any new name on a map level will create the data ( or replace it if exists)

```
dynamic squad = MapList();
squad.name = "Super hero squad";    // String
squad.homeTown = 'Metro City';      // String
squad.formed = 2016;                // int
squad.active = true;                // bool
squad.score = 38.5;                 // double 
```

### Creating and setting maps or lists
#### empty structures
```
dynamic squad = MapList();
// create a list and a map  
squad.members = [];              // empty list
squad.myMap = {};                // empty map   
```
##### addAll to a Map
```
dynamic car = MapList();
car.name = "Ford";
car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false});
```
##### add & addAll to a List
```
dynamic list = MapList([]);  
list.add(15);
list.addAll([1, 2, 3]);
```

#### larger structures
##### add to a List
```
squad.members = [];
// add a full structure to the previous  list
squad.members.add({
    "name": "Molecule Man",
    "age": 29,
    "secretIdentity": "Dan Jukes",
    "powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]
});
```

### Nullable capacities
#### Check null while accessing
To avoid the error **"NoSuchMethodError: The getter 'someData' was called
on null"** while accessing data, MapList allows the nullable notation.  
The following code will return null or the data, in any case
without throwing error if *wrongName* doesn't exist
```
store.wrongName?.someData
```
##### List with wrong index and continuation
 To avoid a crash error,  MapList returns null if an existing list is accessed with a wrong index :
```
assert(store.book[400] == null);
->** wrong index [400]. null returned
```
( MapList send error's trace on stderr to have no dependencies on a logger. Feel free to replace)

#### Nullable available on unexisting index in a list
To avoid a crash on a further call on null , the nullable is available after the index :
```
assert(store.book[400]?.author == null);
```
#### Non existing List - Dart restriction
 if the List doesn't exists at all, the nullable must be checked before
 the index to avoid *"NoSuchMethodError: The method '[]' was called on
 null."* The following run without errors :

```
assert(store.bookList?[0]==null); // won't compile before Dart 2.9
```
Dart allows this syntax **only with Dart 2.9** (which is in beta when
writing ), so it's not yet available in unit test.
*Error: This requires the 'non-nullable' language feature to be
enabled.Try to set the minimum SDK constraint to 2.9 or higher*  
( but current MapList interpreter implements such a nullable on a list )

### data types
A choice was made to avoid runtime conflicts on data types in maps or lists.  
MapList standardises data on the Dart json model :
- maps
  - ```Map <String, dynamic>```    *(precisely the _InternalLinkedHashMap<String, int>)*
- lists:
  - ```List  <dynamic >```
### Automatic conversion in MapList
A conversion is made by MapList when a new entry comes in :
- At the initial construction
- When adding some Json_like structure  
For example ```scores=[10,11,12]``` will not stay a a *```List\<int>```* but will be converted to a *```List\<dynamic>```*  
This allows free structure as the following:
```
 root = MapList();
 root.data = [11, 12, 13];
//as is, data is a List<int> that MapList converts to dynamic.
root.data.add("hello");   // ok 
```
**More samples in unit tests**

### Trapped errors
Some errors are trapped by MapList in order to avoid runtime crash, especially in interpreter.  
Mainly, the trapped errors send a message on **stdErr** and **return null on a getter**  and **leave unchanged on a setter**.  
*( To restore a higher level of trap, can add a throwException(); where stdErr is used )*

#### Sample : wrong json message
```
dynamic root = MapList('{"this": is not a[12] valid entry }');
stderr : -> ** wrong data. MapList will be null :  FormatException: Unexpected character (at character 10)
{"this": is not a [12] valid entry }
       ^   
```
**More samples in unit tests**

-------------------------------
### Loading json from text  ( file or message )
MapList can be constructed initially with any json or any valid json
string. Below are examples to load such data from a file.
```
var file = File(someFileName);
var jsonString = file.readAsStringSync();
dynamic root = MapList(jsonString);
// can stay on root 
print(root.store.book[0].title);
```
---
### Sample with Yaml
 You can use MapList on a Yaml structure loaded with the dart yaml package   .
 As the default Yaml Maps and Lists are **read only**, MapList
 converts the structure to a standard json at first load.
```
var file = File(someFileName);
var yamlString = file.readAsStringSync();
var yamlStructure = loadYaml(yamlString);
dynamic root = MapList(yamlStructure);
```

---
# part 2 : MapList Interpreter
This work is a first step to a larger interpreter in mind.  
This part allows getter and setter on structured data in script.  

## constructors
All the MapList constructors ca be used; The most useful, for example on a received message in string, is the following.
```
MapList(jsonString); // create any structure with a valid json string
 ```
### Accessing data
Each MapList have a method **script(some string)** to interpret a path.  
Every notation (classical or dot notation ) is allowed.  
Assuming *root* is a loaded MapList with a first entry *show* , you can get data named by a string as follow :


```
// classical notation 
root.script('["show"]["videos"][1]["questions"][1]["name"]')
// dot notation  (preferred)
root.script("show.videos[1].questions[1].options[2].answer")
// even, for some unknown reason, a mix is allowed  
root.script('show["videos"][1].questions[1]["options"][2].name')
```
#### Summary of allowed direct assignements
As data arrive in text, MapList recognize the following and convert it in the right type:

| Type                | samples                                                                                  |
|:--------------------|:-----------------------------------------------------------------------------------------|
| string              | ```"hello", 'hello'```        with the other string wrapper than one at script( ) level. |
| bool                | ```true, false    ```                                                                    |
| int                 | ```15 , -1 , 0   ```                                                                     |
| double              | ``` 2.899, -0.125 ```    (more generally what react ok to num.tryParse                   |
| map                 | ``` { }   ```                                                                            |
| list                | ```[ ] ```                                                                               |
| any valid structure | ```{"name":"toto", "score": [11,15,8]} ```                                               |

#### Samples of setters in a map by script

```
dynamic squad = MapList();
squad.script('name = "Super hero squad"'); // String with '" "'
squad.script("homeTown = 'Metro City'");   // String with "' '"
squad.script('formed = 2016');             // int
squad.script('active = true');             // bool
squad.script('score = 38.5');              // double 
```
### Creating and setting maps or lists
#### empty structures
```
dynamic squad = MapList();
squad.script('name = "Super hero squad"'); // String entry
squad.script ('members = []');              // Empty list names members 
```
##### script addAll to a Map
```
dynamic car = MapList();
car.script('name = "Ford"');
    car.script('addAll({ "price": 5000, "fuel":"diesel","hybrid":false})');
```
##### script add & addAll to a List
```
dynamic list = MapList([]);  
list.script('add(15))';
list.script('addAll([1, 2, 3]');
```

#### script with larger structures
( Dart format string on several lines with several ' ' )

```
squad.script('members = []');
squad.script(
    'members.add({ "name": "Molecule Man","age": 29,"secretIdentity": "Dan Jukes",'
    '"powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]})');
```
## Nullable capacities
Script takes care of nullable notationsat all levels  :

```
store.script('wrongName?.someData')
store.script("book[4]?.author
store.script("bookList?[0]")
store.script("bookList?[0]?.date")
```
#### Caution : special interpreted name : *length*
MapList takes care of the *.length* item as it could be a valid entry in a
map or a question about the physical length of the map or the list.  
**MapList always return the length of a List or a Map on .length**
If some data is named length in a data set, it can be reached only with the standard notation :
```
// {"category": "road", "model": "Propel advanced Disc ", "color": "grey",  "price": 2900, "length": 2.20 }
assert(store.script('bikes[1].length')== 5);       // size of the map bikes[1] 
assert(store.script('bikes[1]["length"]')== 2.2); // property length of bikes[1]
 ```
(free advice : avoid to name property 'length'. Here we can have 'lengthOfBike')

---
  # A look inside
  ## classes
   **MapList** is a wrapper class around a unique * json*.  
   **MapListList** and **MapListMap** are two derived classes to take care of specific access.
#### about *is*
A MapList cannot be checked by *'is Map'* or *'is List'*, but by **'is MapLisList'** or **'is MapListMap'**  
*( one can always check (myMapList.json is Map) or (myMapList.json is List))*
An attempt was made with *ListMixin* and *MapMixin* respectively on MapListList and MapListMap, this leaves unresolved conflicts due to same inheritance from MapList.

```
root = MapList({"members": [ { "name": "Bourne", "age": 33 }]});
assert(root is MapList);
assert(root is MapListMap);
assert(root.members is MapList);
assert(root.members is MapListList);
assert(root.members[0] is MapListMap);
assert(root.members[0].name is String);
```
### how dot notation works in Dart
#### noSuchMethod on a MapList to access data
MapList is dynamic and use **dart:mirrors**  to use and override the  **noSuchMethod**  
When a dot notation is compiled by Dart, Dart will call individuals parts and use the result for the next call :
```
root.a.b.c[2].d = 33 
```
1-Dart calls *noSuchMethod ('a')* to the MapList root.  
2-MapList *returns a new MapList*( a MapListMap ) with a shift json inside ( not a copy, on the same pointers)  
3- Dart calls *noSuchMethod ('b')* on the returned MapList, which returns a new MapList (a MapListMap) shifted on b as first entry.  
4- Dart calls *noSuchMethod ('c')* on the returned MapList, which returns a new MapList (a MapListList) shifted on c as first entry.  
5-Dart calls *operator \[1]* on the received MapList that chains to the \[1\] operator on the internal MapListList, which returns again a shifted MapList  
6-Dart calls  *noSucheMethod (' d=', 33)* to the MapListMap that apply the assignement and return nothing.

###### how dot notation works in interpreter
The access in interpreted don't use the noSuchMethod of MapList, but progress internally on the current structure.
```
root.script("a.b.c[2].d["price"] = 33");
```
The received String is split around the. and analyse each part :
1-a
2-b
3-c\[2] : when brackets are found, a second internal loop runs to solve indices : find c, try a c[2]
4-d\["price"] : for tutorial sample (better to use b.price ) : when brackets are found, they are applied once the dry name solved : d, then price key.  
5- = 33 : apply the value.

### odds & ends
 **some utility methods**
  The following are available directly on MapList and  use internal data methods
```
get isEmpty     => json.isEmpty;
get isNotEmpty  => json.isNotEmpty;
clear()         => json.clear();
get hashCode    => json.hashCode;
```

 ** caution on path name in script **
The left path is the same in code or script, without quotes :
```
book.name = "zaza"
book.script('name = "zaza"');
```
If you over quote a path , you are able to create another entry :
```
book.script('"name"="zorro"');
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
print(blackboard.script('store.book[1].isbn'));
if (blackboard.script('squad.members[2].powers.Radiation resistance) != null)...
```


