# MapList
## Access json, maps, lists and data with a dot notation
## In code or in script
### Sample in code
    root.show.name
    root.show.videos[1].name
    root.show.videos[1].questions[1].options[2].answer
### Same sample in script
    root.script("show.name")
    root.script("show.videos[1].name")
    root.script("show.videos[1].questions[1].name")
    root.script("show.videos[1].questions[1].options[2].answer")
#### Classical code with maps and lists
    root["show"]["name"]
    root["show"]["videos"][1]["name"]
    root["show"]["videos"][1]["questions"][1]["name"]
    root["show"]["videos"][1]["questions"][1]["options"][2]["answer"]
## Taking care of null
### Check null while accessing
If some part on the path returns null, Dart can't continue as it will
try to call methods on null :

        assert(store.wrongName == null);  // ok 
        assert(store.wrongName.someData == null)  // NoSuchMethodError: The getter 'someData' was called on null
#### Use non-nullable notation
To avoid this, Dart allows the use of non nullable **?**  
The following work in code and in script :

        assert(store.wrongName?.someData==null);
        assert(store.script("wrongName?.someData")==null);

##### Null on existing List but wrong index
 If a list exists (here book is a List) and a wrong index is used, the
 result is null on the list.

    // in code  
        assert(store.book[4] == null); 
    // in script    
        assert(store.script("book[4]") ==  null);
  But if something goes ahead after a null , same care must be taken:

    //in code, you must use nullable notation  
        assert(store.book[4].author == null); // NoSuchMethodError: The getter 'author' was called on null.   
        assert(store.book[4]?.author == null);   
    // in script
        assert(store.script("book[4]?.author") == null);
#### Non existing List with an index
**if the List doesn't exists** (here bookList):  
As expected, code will failed with an error.  
Script have some tolerance as it can detect that the list is null before
applying index :

    //code 
        assert(store.bookList == null);  
        assert(store.bookList[0]==null); // NoSuchMethodError: The method '[]' was called on null.
    // script     
        assert(store.script("bookList") == null);  
        assert(store.script("bookList[0]") == null); // it's an implementation choice: null rather than an error 


#### Using nullable to check list existence
The common code must be to test nullable before the [].  
If the script do it right now, the code must be updated to a high level
of language :

    // code
        assert(store.bookList?[0]==null); // won't compile before Dart 2.9 
    //script
        assertShow(store.script("bookList?[0]"), null);    
        assertShow(store.script("bookList?[0].date"), null);

Dart allows this syntax **only with Dart 2.9** (which is in beta when
writing ), so it's not yet available in these examples  
*Error: This requires the 'non-nullable' language feature to be
enabled.Try to set the minimum SDK constraint to 2.9 or higher*

----------------------------------------------------------
# Constructors

To simplify the construction, MapList allows a (coded inside)
polymorphic constructor :

    dynamic root = MapList();           // create a first empty node as a Map (default) 
    dynamic root = MapList({});         // same as previous. More explicit.
    dynamic root = MapList([])          // create a first empty node as a List 
    dynamic root = MapList(jsonString); // create a full structure with a valid json string
    dynamic root = MapList(someStructure);  // uses an already 'maps & list' structure as a Dart json object

*( this polymorphism of constructor is hand made : the type of parameter
is checked in the MapList class)*

## get data
Once loaded with a set of data, the getter are available in code and in
script:

    // code  
        if (root.store.bikes[1].color == "grey") ...
    // script
        if (root.script("store.bikes[1].color") == "grey") ...
## set data
### on an existing entry
    // code
            root.store.bikes[1].color = "blue";
    // script 
            roort.script('store.bikes[1].color = "blue");
### create new data in a Map
    // in code 
        dynamic squad = MapList();
        squad.name = "Super hero squad";    // String
        squad.homeTown = 'Metro City';      // String
        squad.formed = 2016;                // int
        squad.active = true;                // bool
        squad.score = 38.5;                 // double
    // in script 
        dynamic squad = MapList();
        squad.script('name = "Super hero squad"'); // String with '" "'
        squad.script("homeTown = 'Metro City'");   // String with "' '"
        squad.script('formed = 2016');             // int 
        squad.script('active = true');             // bool
        squad.script('score = 38.5');              // double 

### Sample : create a List in a Map and fill an entry with another map
    // in code 
        //create a list in the previous map 
            squad.members = [];
        // assign a full structure in one shot
            squad.members.add({
                "name": "Molecule Man",
                "age": 29,
                "secretIdentity": "Dan Jukes",
                "powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]
            });
        // control 
            assert(squad.members[0].powers[1] == "Turning tiny");            

Same in script (except Dart formatting for long string)

    // in script 
        squad.script('members = []');
        squad.script(
            'members.add({ "name": "Molecule Man","age": 29,"secretIdentity": "Dan Jukes",'
            '"powers": ["Radiation resistance", "Turning tiny", "Radiation blast"]})');
        assert(squad.members[0].powers[1] == "Turning tiny");

## Summary of assignements

| Type                | samples                              |
|:--------------------|:-------------------------------------|
| string              | "hello", 'hello'                     |
| bool                | true, false                          |
| int                 | 15 , -1 , 0                          |
| double              | 2.899, -0.125                        |
| map                 | { }                                  |
| list                | [ ]                                  |
| any valid structure | {"name":"toto", "score": \[11,15,8]} |

| Assignment on existing entry | usage                 | sample                    |
|:-----------------------------|:----------------------|:--------------------------|
| =  (equals)                  | on a map entry        | car.color= "blue"         |
| =                            | on a member of a list | car.options\[1] = "hi-fi" |

| Create new entries | usage     | samples                                                                      |
|:-------------------|:----------|:-----------------------------------------------------------------------------|
| = (equals)         | on a map  | car.price = 25000 (will replace if exists)                                   |
| add                | on a list | car.options.add("comfort +");                                                |
| addAll             | on a map  | add several entries to a map:  car.addAll({"fuel":"diesel", "hybrid":false}) |

### About   .length
MapList takes care of the .length as follow in code and script :
- on a List :
  - returns the length of the list
- on a Map
  - if an entry of the map is named "length", returns its value
  - otherwise returns the length of the map







---
## Loading a MapList from a file
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
 You can use MapList on a Yaml loaded with the dart yaml package.  
 **Warning ** : The default Yaml Maps and Lists are **read only**:  
 If uyou use Dart Yaml as is in MapList, you can get data but not set
 data .

 Waiting for a more standard yaml package, for the day you can always
 reparse a yaml in standard json by :
    
    var file = File(someFileName);
    var yamlString = file.readAsStringSync();
    var yamlStructure = loadYaml(yamlString);
    dynamic root = MapList(json.decode(json.encode(yamlStructure)));;




