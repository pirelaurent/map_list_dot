# MapList
## access Json or Json Like with a dot notation,  in code or in script
### Constructors
MapList uses a factory and allows several constructors:

     MapList();           // create a first empty node as a Map (default) 
     MapList({});         // same as previous. More explicit.
     MapList([])          // create a first empty node as a List 
     MapList(jsonString); // create a full structure with a valid json string
     MapList(someStructure);  // uses an already 'maps & list' structure or a Dart json object

### Accessing data
#### Sample in code ( where root is some MapList )
    root.show.name
    root.show.videos[1].name
    root.show.videos[1].questions[1].options[2].answer
#### Same sample in script ( where root is some MapList )
    root.script("show.name")
    root.script("show.videos[1].name")
    root.script("show.videos[1].questions[1].name")
    root.script("show.videos[1].questions[1].options[2].answer")

### Creating data

#### Summary of allowed direct assignements

| Type                | samples                                                         |
|:--------------------|:----------------------------------------------------------------|
| string              | "hello", 'hello'                                                |
| bool                | true, false                                                     |
| int                 | 15 , -1 , 0                                                     |
| double              | 2.899, -0.125     (more generally what react ok to num.tryParse |
| map                 | { }                                                             |
| list                | [ ]                                                             |
| any valid structure | {"name":"toto", "score": \[11,15,8]}                            |

#### creating new entries in a map by code
Any new name on a map level will create the data ( or replace it if
exists)

        dynamic squad = MapList();
        squad.name = "Super hero squad";    // String
        squad.homeTown = 'Metro City';      // String
        squad.formed = 2016;                // int
        squad.active = true;                // bool
        squad.score = 38.5;                 // double

#### creating same entries in a map by script

        dynamic squad = MapList();
        squad.script('name = "Super hero squad"'); // String with '" "'
        squad.script("homeTown = 'Metro City'");   // String with "' '"
        squad.script('formed = 2016');             // int
        squad.script('active = true');             // bool
        squad.script('score = 38.5');              // double

### Creating mixed structures
#### empty structures by code
        dynamic squad = MapList();
        squad.name = "Super hero squad"; // String entry
        squad.members = [];              // Empty list names members
        squad.members.add({});           // members[0] is another map  
#### empty structures by script
        dynamic squad = MapList();
        squad.script('name = "Super hero squad"'); // String entry
        squad.script ('members = []');              // Empty list names members
        squad.script ('members.add({})');           // members[0] is another map
#### Any structured data of json or maps and lists
##### sample in code. Assign a full structure in a list in one shot
        squad.members = [];
            squad.members.add({
                "name": "Molecule Man",
                "age": 29,
                "secretIdentity": "Dan Jukes",
                "powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]
            });
##### same sample in script (except Dart formatting for long string)
        squad.script('members = []');
        squad.script(
            'members.add({ "name": "Molecule Man","age": 29,"secretIdentity": "Dan Jukes",'
            '"powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]})');
        assert(squad.members[0].powers[1] == "Turning tiny");


## Nullable capacities
#### Check null while accessing
To avoid the error "NoSuchMethodError: The getter 'someData' was called
on null" while accessing, MapList allows the nullable notation.  The
following code or script will return null or the data, in any case
without crash if wrongName doesn't exist

        store.wrongName?.someData
        store.script('wrongName?.someData')

##### List with wrong index and continuation
 We made the choice to avoid error and MapList returns null if an
 existing list is accessed with a wrong index :

        assert(store.book[4] == null); 
        assert(store.script("book[4]") ==  null);

#### Nullable available on unexisting index in a list
To avoid a further call on null, the nullable is available after the
index :

       assert(store.book[4]?.author == null);   
       assert(store.script("book[4]?.author") == null);
#### Non existing List
 if the List doesn't exists at all, the nullable must be checked before
 the index to avoid *"NoSuchMethodError: The method '[]' was called on
 null."* The folowing run without errors :

     assert(store.bookList?[0]==null); // won't compile before Dart 2.9 
     assert(store.script("bookList?[0]") == null);    
     assert(store.script("bookList?[0].date") == null);

Dart allows this syntax **only with Dart 2.9** (which is in beta when
writing ), so it's not yet available in these examples  
*Error: This requires the 'non-nullable' language feature to be
enabled.Try to set the minimum SDK constraint to 2.9 or higher*

----------------------------------------------------------


### Adding and changing elementary data

| Create new entries | usage                                       | samples                                       |
|:-------------------|:--------------------------------------------|:----------------------------------------------|
| =                  | on a map entry                              | car.price = 25000 (will replace if exists)    |
| =                  | on an existing list entry                   | car.options\[0] = 'luxus';                    |
| add                | add and initialize a new entry in a list    | car.options.add("comfort +");                 |
| addAll             | add all entries of a map to an existing map | car.addAll({"fuel":"diesel", "hybrid":false}) |
|                    |                                             |                                               |


| Assignment with complex data | usage                    | sample                            |
|:-----------------------------|:-------------------------|:----------------------------------|
| any entry = complex          | on a map entry           | heroes.scores =\[20,50,20];       |
|                              | on a member of a list    | car.options\[1] = {"hi-fi": true} |
|                              | with any structured data | books.book = someJson;            |

#### caution about name '.length'
MapList takes care of the .length item as it could be a valid entry in a
map or a question about the length of the map or the list.  
Behavior of .length :
- on a List :
  - returns the length of the list
- on a Map
  - if an entry of the map is named "length", returns its value
  - otherwise returns the length of the map


---
## Loading Json from a file
MapList can be constructed initially with any json or any valid json
string. Below are examples to load such data from a file.
### Sample with json
    var file = File(someFileName);
    var jsonString = file.readAsStringSync();
    dynamic root = MapList(jsonString);
    // can stay on root 
    print(root.store.book[0].title);
    // can relay on entries 
    dynamic store = root.store;
    print(store.book[2].title;

---
### Sample with Yaml
 You can use MapList on a Yaml loaded with the dart yaml package (not
 directly a yaml string)

 As the default Yaml Maps and Yaml Lists are **read only**, MapList
 converts the structure to a default json types at first load. ( with an
 rather ugly json.decode(json.encode(yamlStructure))
    
    var file = File(someFileName);
    var yamlString = file.readAsStringSync();
    var yamlStructure = loadYaml(yamlString);
    dynamic root = MapList(yamlStructure);

---
  # A look inside
  ## classes
   **MapList** is a wrapper class around a dynamic* wrapped_json*.  
   **MapListList** and **MapListMap** are two derived classes to take care of specific access.
#### about *is*
A first attempt was made with *ListMixin* and *MapMixin* respectively on MapListList and MapListMap. But as they both inherit from a common MapList, this created unresolved conflicts.
As a consequence, a MapList cannot be testes with *'is Map'* or *'is List'*, but must check **'is MapLisList'** or **'is MapListMap'**
*( one can allways check MapList.wrapped_json is Map (or is List), but it's not the best idea)*

    root = MapList({"members": [ { "name": "Bourne", "age": 33 }]});
    assertShow(root is MapList, true);
    assertShow(root is MapListMap, true);
    assertShow(root.members is MapListList, true);
    assertShow(root.members[0] is MapListMap, true);
    assertShow(root.members[0].name is String, true);

## data types
A choice was made to avoid runtime conflicts on data types in maps or lists.  
MapList standardise on the Dart Json model :
- maps
  - Map \<String, dynamic>    *(precisely the _InternalLinkedHashMap<String, int>)*
- lists:
  - List  \<dynamic >
### converting data types
A conversion is made by MapList when a new entry comes in :
- At the initial construction
- When adding a value responding positive to a regex that detect some Json_like structure

For example, adding *scores=\[10,11,12]* will not stay a a *List\<int>* but will be converted to a *List\<dynamic>*
By this way, all constructions are allowed ( like to add a map to the previous list )

## use of noSuchMethod on a MapList to access data
MapList is dynamic and use **dart:mirrors**  to use and override the  **noSuchMethod**
### access in dart code
When a dot notation is compiled by Dart, Dart will call individuals parts and use the result to the next call :

    root.a.b.c[2].d = 33 
Dart calls *noSuchMethod ('a')* to the MapList root.  
MapList **returns a new MapList **( a MapListMap ) with a shift wrapped_json inside ( not a copy, the pointer)  
Dart calls* noSuchMethod ('b')* on the returned MapList, which returns a new MapList (a MapListMap) shifted on b as first entry.

Dart calls* noSuchMethod ('c')* on the returned MapList, which returns a new MapList (a MapListList) shifted on c as first entry.  
Dart calls *operator \[1]* on the received MapList that chains to the \[1\] operator on the internal List, which returns again a shifted MapList
Dart calls  *noSucheMethod (' d=', 33)* to the MapList that apply the assignement and return nothing.

### access with script
Scripts need an additional step :

     root.script("a.b.c[2].d = 33"); 
The received String is split around the. :  
MapList search for 'a' using the noSuchMethod ('a') on the class  
then called recursively
- return script("b.c\[2].d = 33")
- return script("c\[2].d = 33 ")
- return script("d = 33")
- return nothing if last node is x = something ,
- or return data if last node without =

Script analyse the data after **=** in order to convert it from string to the right type first  
Unlike the code, the \[2\] is not called on the operator, but interpreted as an index and applied in script.

### odds & ends
 **More common utility methods**  
  The following are available directly on MapList and  propagate to internal data

        get isEmpty => wrapped_json.isEmpty;
        get isNotEmpty => wrapped_json.isNotEmpty;
        clear() => wrapped_json.clear();
        get hashCode => wrapped_json.hashCode;


 **Caution about dot path name**  
The name part of a path is allways the same in code or script without quotes :

    book.name = "zaza"
    book.script('name = "zaza"');
In case of an over quoted string in interpreter :

    book.script('"name"="zorro"');     
MapList will apply the demand and create another instead of changing name entry :  
*{name: zaza, , "name": zorro, friends: \[{name: lulu}]}*

 **can use MapList relay**  
As a dotted question returns a MapList at every level with a correct shifted json,  
and as the json entries are never copied but stay as pointers,  
one can use intermediate dynamic for commdity:

    dynamic root = MapList(jsonString);
    dynamic store = root.store;
    dynamic bookCollection = store.book;
    dynamic myPrefered = bookCollection[2];   

