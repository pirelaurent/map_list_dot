# MapList :
## access any json or json-like maps & lists with a dot notation
MapList is a wrapper around an internal json-compatible data.  
MapList offers dot notation in Dart code.  
An interpreter is also available to access data with the same notation in textual scripts.
### Constructors
MapList uses a factory and allows several constructors :
```
 MapList();             // create a first empty node as a Map (default)
 MapList({});           // same as previous. More explicit.
 MapList([])            // create a first empty node as a List 
 MapList(jsonString);   // create a full structure with a valid json string
 MapList(someStructure);  // uses an already 'maps & list' structure or a Dart json object
```
# Part1 : dot notation access in Dart
In a MapList, you can then add maps, lists and data , in line or as json.  
In the following  examples, a MapList *root* was first loaded with a large json to test access.
#### classical notation
Classical notation is still available using a MapList ( which apply demands on the wrapped json)
``` dart
root["show"]["name"]
root["show"]["videos"][1]["name"]
root["show"]["videos"][1]["questions"][1]["options"][2]["answer"]
```
##### dot notation available with MapList
Depending of the last leaf, will return a data or a pointer to the sub-structure
``` dart
root.show.name
root.show.videos
root.show.videos[1].name
root.show.videos[1].questions
root.show.videos[1].questions[2].options
root.show.videos[1].questions[2].options[1].answer
```
access a data or an intermediate structure: use name    ```path.name```  
Accessing an element in a List :                        ```name[rank]```  
Accessing an element in a List of List ... :            ```name[rank1][rank2] ...```  
Accessing last element of a List :                      ```name.last```  ```name[rank1].last```

### create & set data
You can create data from scratch, or add and change values or structures to existing in a simple way.
##### create empty structures
``` dart
dynamic squad = MapList(); // create an empty map as root   
squad.members = [];        // add an empty list 'members' in the squad map
squad.activities = {};     // add an empty map 'activities' in the squad map
print(squad);              // {members: [], activities: {}}   
```
##### sample : design and fill in a data object from scratch
Any new name at a map level will create the data if it not exists ( or replace it if exists)
``` dart
dynamic squad = MapList();          // will create a default Map
squad.name = "Super hero squad";    // add a String data 
squad.homeTown = 'Metro City';      // another 
squad.formed = 2016;                // add an int
squad.active = true;                // add a bool
squad.score = 38.5;                 // add a double 
```
##### add new elements
To a MapList from another map or MapList : addAll
``` dart
dynamic car = MapList();
car.name = "Ford";
// add an inline structure
car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false});
```
You can also add a MapList to another to create data more easily:
```
dynamic carInfo = MapList();
carInfo.price = 6000;
carInfo.tires = "slim";
carInfo.color = ["blue","black","white"];
car.addAll(carInfo);
```
```
print(car);         // {name: Ford, color: [blue, black, white], price: 6000, fuel: diesel, hybrid: false, tires: slim}
print(car.color);   // [blue, black, white]
print(car.color[2]); // white
```
Adding new elements to an existing List : add & addAll
``` dart
dynamic list = MapList([]);  
list.add(15);
list.addAll([1, 2, 3]); 
list.add({"date":"october 16"}); 
print(list); //[15, 1, 2, 3, {date: october 16}]
```
### The hell of data types
**get data** : No restriction as long as this data is made of maps, lists and simple types.  
**set data** : MapList rely on *\<String,dynamic> Maps* and *\<dynamic> Lists*, but some settings can depend on the previous added data types.
#### Json alignment
Standard Dart json uses **Map\<dynamic,dynamic>** and **List\<dynamic>**  
MapList  uses the subset **Map\<String,dynamic>** as it's mandatory to get data with a printable String name for dot notation.
#### warning with inline coded structures
If a type is not indicated, Dart infers the type from the current assignment:  
```[1,2,3,4]``` will be a ```List<int>```. From there, you can only add other ```<int>``` without errors, nothing else.  
if you try to add a *String* or a *Map* Dart will crash with error.

#### think about adding Types to the inline structures
If you plan to have another data type than the guessed one by Dart, think to add type:  
This code fails:
``` dart
root.results.add({"elapsed_time": 30, "temperature": 18}) // is ok but with an inferred  Map<String, int>  
root.results[0].time = "12:58:00";        // will fail : type 'String' is not a subtype of type 'int' of 'value'
```
This code will not fail :
``` dart
root.results.add( <String,dynamic>{"elapsed_time": 60, "temperature": 40});
root.results[0].time = "12:58:00"; // now ok ! 
```
This code with a List will fail:
```
root.data = [11, 12, 13];   // will infer a List<int> 
root.data.add(14);          // ok
root.data.add("hello");     // will fail :type 'String' is not a subtype of type 'int'
```
This code will not fail:
```
root.data = <dynamic>[11, 12, 13];
root.data.add("hello");   // ok 
```
**More samples in unit tests**
#### Check nullable while accessing data
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
print(store.book[400]);  
    // WARNING: unexisting book [400] : null returned .
    // Original message : RangeError (index): Invalid value: Not in range 0..3, inclusive: 4 
```
As first step is null, you must protect downstream with a nullable option :
```dart
store.book[400]?.author = "zaza" ;  
```
#### Non existing List & Dart restriction on nullable
 if the list doesn't exists at all, the nullable must be checked **before the index** to avoid error on operator [ ]:
``` dart
store.pocketBookList?[0].author = "zaza";
```
Caution : Dart allows this syntax **only with Dart 2.9**.  
Before 9.2 you cannot compile with a nullable before \[0\] in code, but it is already available in the interpreter.

### Logged errors
MapList try to avoid runtime errors: If something is wrong, it logs Warning and continue :
- On a wrong get, it logs message and  returns null .
- On a wrong set : it logs message and do nothing else .  
To see the messages, you must set a logging listener in your code (@see standard logging package).
#### common warning : using List as Map or Map as List
**WARNING:** index \["toto"\] must be applied to a map. no action done.
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
Wrong json data in a String at runtime (if inline code, compiler will warn )
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
### some details
A MapList has a *.json* accessor to get the wrapped one if necessary.  
MapList works with pointers, not copies : data can stay synchronised between MapList in code, interpreter's call, some object with internal json, etc.  
( More technical details are in a Readme_more.md on the github. )


---
---
# part 2 : MapList Interpreter
This interpreter can get and set data through execution of textual scripts.  
You need a root *MapList* in order to access to its  *exec* method .
### general syntax
*someMapList*.**exec**(*'script command'*);  
script command to get data : **'dot location'** It will return data or null  
script command to set data : **'doc location = value'** It will set data or do nothing if something wrong.  
Interpreter logs warning in case of some identified error.
#### scripts to get data samples
classical :     ```'["show"]["videos"][1]["questions"][1]["name"]'```  
dot notation:   ```'show.videos[1].questions[1].options[2].answer'```  
Mix (but why?): ```show["videos"][1].questions[1]["options"][2].name```  
Depending of the named leaf, get will return a data or a pointer to the sub-structure.  
Scripts must be called on a MapList and path starts **after** this level:  
In direct Dart code :
``` dart
dynamic root = MapList(myJson);  
root.show.videos
```
With interpreter :
``` dart
dynamic root = MapList(myJson);  
root.exec('show.videos');
```
Scripts samples :
``` dart
'show.name'
'show.videos'
'show.videos[1].name'
'show.videos[1].questions'
'show.videos[1].questions[2].options'
'show.videos[1].questions[2].options[1].answer '
```
#### special words in script while getting data
These words returns values *about* the data :  
**.isEmpty** or **.isNotEmpty** : returns true/false according to the named List or Map  
**.length** : returns an int, the length of the named List or Map  
if a map has a property named 'length' (bad idea), *.length*  will return the size of the map.  
To reach the property itself, you can use standard notation :
```dart
store.exec('bikes[1].length'); // size of the map bikes[1] 
store.exec ('bikes[1]["length"]'); // property length of the bike in bikes[1]
 ```
**.last**  : pointer on last element of a List .

#### scripts to create or set data
The interpreter looks at an equal sign (out of quoted string) to spot a setter.  
The syntax is  ***exec('path = data')***  
As data arrive in a text format , MapList converts it as follow:

| Type                | samples                                    | comments                                                    |
|:--------------------|:-------------------------------------------|:------------------------------------------------------------|
| string              | ```"hello" or 'hello'```                     | within the other quotes than the ones at exec( ) level. |
| bool                | ```true, false    ```                      | these lower case words without quotes becomes booleans            |
| int                 | ```15 , -1 , 0   ```                       | simple number without quotes becomes an integer             |
| double              | ``` 2.899, -0.125 ```                      | more usually any valid response to *num.tryParse* is transformed          |
| map                 | ``` { }   ```                              | an empty map                                                |
| list                | ```[ ] ```                                 | an empty list                                               |
| any valid structure | ```{"name":"toto", "score": [11,15,8]} ``` | more usually any valid json equivalent string.              |
##### full example
``` dart
dynamic root = MapList();
root.exec('squad = {}'); // create a new map entry at root 
root.exec('squad.name = "Super hero squad"'); // String within " ", script within ' '
root.exec("squad.homeTown = 'Metro City'");   // String within ' ' , script within " ",  allowed but prefer the previous 
root.exec('squad.formed = 2016');             // int
root.exec('squad.active = true');             // bool
root.exec('squad.score = 38.5');              // double 
root.exec('squad.members = []');              // add an empty list 
// adding another set of data at root  
root.exec('car = {"name":"Ford", "color":"white"}'); // create and set with json-like string. 
root.exec('car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false})'); //add or merge with function addAll
```
#### special  words to create or update data
**.clear()**  clear the named location, map or list  
**.add(something)**  Only for Lists : add a new element  
**.addAll(several something)**  Add all elements of a map to a map or all elements of a list to a list.  
**.remove(something)**   Remove an entry of a map or an element in a list/
**.length = \<int>**  Force the length of a List

**\[last\]** Access to the last element of a list.
```dart
root.exec('contacts.add([]');
root.exec('contacts[last] = {"name" : "polo", "firstName" : "marco"}'); 
```

#### errors and logs
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

