# MapList :
## access any json or json-like maps & lists with a dot notation
MapList is a wrapper around any kind of json-compatible data.  
MapList offers dot notation in Dart code and an interpreter to access data via script  commands.
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
Only the first level needs to be a MapList. You can then add directly maps, lists and data , in line or as json.  
In the following  examples, a MapList *root* has been loaded with a json.
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
You can create data from scratch, or add and change value or structures to existing in a simple way.
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
print(car);     //{name: Ford, price: 5000, fuel: diesel, hybrid: false}
// or add another prepared MapList here with adds and updates inside
dynamic carInfo = MapList();
 carInfo.price = 6000;
 carInfo.tires = "slim";
 carInfo.color = ["blue","black","white"];
car.addAll(carInfo);
print(car); // {name: Ford, color: [blue, black, white], price: 6000, fuel: diesel, hybrid: false, tires: slim}
print(car.color); // [blue, black, white]
print(car.color[2]); // white
```
Adding new elements to a List : add & addAll
``` dart
dynamic list = MapList([]);  
list.add(15);
list.addAll([1, 2, 3]); 
list.add({"date":"october 16"}); 
print(list); //[15, 1, 2, 3, {date: october 16}]
```
### The hell of data types
**get data** : There is no restriction to get data, as long as the structure is made of maps, lists and simple types.  
Any inline structure of maps & lists, any json or any yaml structure can be accessed with dot notation.  
**set data** : MapList rely on **\<String,dynamic> Maps** and **\<dynamic> Lists**, which are full compatible with json format :
#### Json alignment
Standard Dart json uses **Map\<dynamic,dynamic>** and **List\<dynamic>**  
MapList  uses the subset **Map\<String,dynamic>** as it's mandatory to get data with a printable String name for dot notation.
#### warning with inline coded structures
If type is not indicated, Dart guess the type from the current data:  
```[1,2,3,4]``` will be set as a ```List<int>```. From there, you can only add other ```<int>``` , nothing else.  
if you try to add a *String* or a *Map* Dart will crash with error.

#### think about adding Types to the inline structures
If you plan to have another data type than the guessed one by Dart, add type:  
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
Same with Lists. This code will fail:
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
assert(store.bookList?[0]==null); // good idea but won't compile before Dart 2.9
```
Dart allows this syntax **only with Dart 2.9** Cannot be used on lower. (as is this work)

### Logged errors
MapList try to avoid runtime errors.  
If something is wrong, it does'nt throw errors but logs Warning and continue.  
On a wrong get, it logs message and  returns null .  
On a wrong set : it logs message and do nothing else .  
-> Think about instantiate a real logging listener in your code to see these warning messages.
#### most common warning :
Use Map as List or List as Map
```dart
aList["toto"]="riri"    WARNING: index ["toto"] must be applied to a map. no action done.   
aMap[0]="lulu":         WARNING:  [0] must be applied to a List. no action done.
print(aList.price);      WARNING:  ** Naming error: trying to get a key "price" in a List. null returned    
```
Wrong index in List
```dart
print(root[200]);       WARNING:  unknown accessor: . [200] : null returned .(followed by original dart error 'Not in range..') 
```
Wrong json data in a String at runtime (if inline code, compiler will warn )
``` dart
dynamic root = MapList('{"this": is not a[12] valid entry }'); ** wrong json data. null returned .(followed by original conversion error) 
```
##### remaining runtime that can throw errors
Types errors :  if inline data are not correctly casted as explained previously.  
My main oversight is about using Yaml directly and try to update:
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
---------------------------------------------------------------------
---
# part 2 : MapList Interpreter
This is a first step with a wider interpreter in mind.  
It can get and set data through text scripts.  
To execute demands in the main code, you just have to create a root *MapList*, starting with an empty or a large structure.
### general syntax
*someMapList*.**exec**(*'script command'*);  
script command : **'dot location' |  'doc location = value'**  
The first manner will return the data or null  
The second manner will create or set a data, and do nothing if something wrong.
#### scripts to get data
Same as dot notation in code:  
classical :     ```'["show"]["videos"][1]["questions"][1]["name"]'```  
dot notation:   ```'show.videos[1].questions[1].options[2].answer'```  
Mix (but why?): ```show["videos"][1].questions[1]["options"][2].name```
Depending of the named leaf, get will return a data or a pointer to the sub-structure.
(remember : scripts must be called at the root level : *root.exec(script) *
``` dart
Scripts : 
'show.name'
'show.videos'
'show.videos[1].name'
'show.videos[1].questions'
'show.videos[1].questions[2].options'
'show.videos[1].questions[2].options[1].answer '
```
#### reserved word in script to get data
 some special terms can be uses in a get script and returns special values :

**.isEmpty**   : true/false  
**.isNotEmpty**: true/false  
**.length** : int  
**.last**  : pointer on last element of a List . can be used in set too.
##### about .length
**MapList always return the length of a List or a Map on something.length**  
if in your data has a property named *length*, it can be reached only with the standard notation :
```
// {"category": "road", "model": "Propel advanced Disc ", "color": "grey",  "price": 2900, "length": 2.20 }
assert(store.exec('bikes[1].length')== 5);       // size of the map bikes[1] 
assert(store.exec ('bikes[1]["length"]')== 2.2); // property length of bikes[1]
// free advice : avoid to name a property 'length'. Here we can have choosen 'lengthOfBike'
 ```
#### scripts to create or set data
The interpreter looks at some equal sign to spot a setter.  
The syntax is  ***set('path = data')***  
As data arrive in a text format , MapList recognize the following and convert it in the right type:

| Type                | samples                                    | comments                                                    |
|:--------------------|:-------------------------------------------|:------------------------------------------------------------|
| string              | ```"hello", 'hello'```                     | with the other quote wrapper than the one at exec( ) level. |
| bool                | ```true, false    ```                      | lower case text without quotes  becomes booleans            |
| int                 | ```15 , -1 , 0   ```                       | simple number without quotes becomes an integer             |
| double              | ``` 2.899, -0.125 ```                      | more usually any valid response to *num.tryParse*           |
| map                 | ``` { }   ```                              | an empty map                                                |
| list                | ```[ ] ```                                 | an empty list                                               |
| any valid structure | ```{"name":"toto", "score": [11,15,8]} ``` | more usually any valid json equivalent string.              |
##### full sample

``` dart
dynamic root = MapList();
root.exec('squad = {}'); // create a new map entry at root 
root.exec('squad.name = "Super hero squad"'); // String with '" "'
root.exec("squad.homeTown = 'Metro City'");   // String with "' '"
root.exec('squad.formed = 2016');             // int
root.exec('squad.active = true');             // bool
root.exec('squad.score = 38.5');              // double 
root.exec('squad.members = []');              // add an empty list 
// adding another set of data at root  
root.exec('car = {"name":"Ford", "color":"white"}'); // create and set with json-like string. 
root.exec('car.addAll({ "price": 5000, "fuel":"diesel","hybrid":false})'); //add or merge with function addAll
```
#### reserved word in script to set or change data
 some special functions can be used in script to set data :  
**.clear()**  
**.add(something)**  
**.addAll(several something)**  
**.remove(something)**  
**.length = \<int>**  :force the length of a List

#### logs on wrong script
don't forget the () for the function
```dart
root.exec('clear'); // WARNING cannot search a key (clear) in a List<dynamic> 
root.exec('clear()'); // ok 
 ```
## Nullable capacities
Interpreter takes care of nullable notations at all levels  :
```
store.exec('wrongName?.someData')
store.exec("book[4]?.author
store.exec("bookList?[0]")   // Even if Dart is not in 9.2, the interpreter allows this nullable.    
store.exec("bookList?[0]?.date")
```

