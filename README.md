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
If some part on the path returns null, dart can't continue as it will
try to call methods on null :

        assert(store.wrongName == null);  // ok 
        assert(store.wrongName.someData == null)  // NoSuchMethodError: The getter 'someData' was called on null
#### Use non-nullable notation
To avoid this, Dart allows the use of non nullable **?**  
The following work in code and in script :

        assert(store.wrongName?.someData==null);
        assert(store.script("wrongName?.someData")==null);

### Check null on lists
#### Existing List and wrong index
 If a list exists (here book is a List) and a wrong index is used, the
 result is null.  
 If something goes ahead, same care must be taken with null:

    // in code  
        assert(store.book[4] == null); //ok 
        assert(store.book[4].author == null); //NoSuchMethodError: The getter 'author' was called on null.
    // so must use nullable in code
        assert(store.book[4]?.author == null); //ok
    // with script : same thing 
        assert(store.script("book[4]") ==  null);
        assert(store.script("book[4]?.author") == null);
#### Non existing List
But **if the List doesn't exists** (here bookList):  
The As expected, code will failed, while script have some tolerance:

    //code 
        assert(store.bookList == null);  
        assert(store.bookList[0]==null); // NoSuchMethodError: The method '[]' was called on null.
    // script     
        assert(store.script("bookList") == null);  
        assert(store.script("bookList[0]") == null); //ok


#### Using nullable
The common code must be to test nullable before the [ ]. The script do
that right now:

    //script
        assertShow(store.script("bookList?[0]"), null);    
        assertShow(store.script("bookList?[0].date"), null);

But Dart allows this syntax **only with Dart 2.9** (which is in beta
when writing ), so it's not yet available in these examples and syntax
doesn't compile :

    // code
    assert(store.bookList?[0]==null);


**Error: This requires the 'non-nullable' language feature to be
enabled.**  
**Try to set the minimum SDK constraint to 2.9 or higher**

----------------------------------------------------------

# Work with Data
## Constructor

To simplify the construction, MapList allows a (coded inside)
polymorphic constructor :

    dynamic root = MapList();           // create a first empty node as a Map (default) 
    dynamic root = MapList([])          // create a first empty node as a List 
    dynamic root = MapList(jsonString); // create a full structure with the (correct) json string
    dynamic root = MapList(someJson);  // uses an already structured dart json object

*( this polymorphism of constructor is hand made : the type of parameter
is checked in the MapList class)*

### check data loaded
Once loaded with a set of data, the getter are available in code and in
script:

    // code  
        if (root.store.bikes[1].color == "grey") ...
    // script with a string sample 
        String path = "store.bikes[1].color";
        if (root.script(path) == "grey") ...


## Create data structure on the fly : assignments
### add new map elements to a list

        dynamic root = MapList();
        root.results = [];
    // code: add maps to a list 
        root.results.add({"elapsed time": 30, "temperature": 18  , });
        root.results.add({"elapsed time": 60, "temperature": 40  , });
        assert(root.results[1].temperature ==  40);
    // script: add another map to the list 
        root.script('results.add({"elapsed time": 120, "temperature": 58  })');
        assert(root.results[2].temperature ==  58);

### add new entries to a map
 if a non existing name is assigned with a value, MapList will create it
 :

     // code
      root.results[1].time = "12:58:00";
      // script
      root.script('results[1].elapsedTime = "01:00:00"');
### change existing values







---
---
## About working with Yaml
 You can use MapList on a Yaml loaded with the dart yaml package.  
 If this is ok for all the getters, this is not for the setters :  
 The default Yaml Maps and Lists are read only.

 Waiting for a more standard yaml package, for the day you can always
 reparse a yaml in standard json *( as do dot_access_test ) *by :
    
    var xYaml = loadYaml(yamlString);
    dynamic root = MapList(json.decode(json.encode(xYaml)));;



# Internal
The root of data must be a *MapList* and subtrees must be accessed
through the dot notation and be declared as dynamic:

    dynamic root = MapList(jsonString);
    dynamic store = root.store;  

When *root* receive a *.store* , it find the corresponding json subtree
then return it as a MapList to allow further steps.


