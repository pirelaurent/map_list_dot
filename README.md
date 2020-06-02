# Dot notation to Access data
## Motivation
In Dart, a data structure can always be defined through Maps, Lists
and values.  
In particular, this is the case with a ***json*** object

With or without an object model made of classes behind, you can always
use the maps and lists notation like:

`root["show"]["videos"][1]["name"]`

Which use a map *root*, a list *videos* made of maps with property
*name*

## MapList allows to use .notation on Maps and Lists
Using a MapList on the same previous structure allows to use a dot notation :

    root.show.videos[1].name

## More : can be used with an internal interpreter :

    root.interpret("show.videos[1].name")

# use case
## Act on a json as if it was structured classes
On receipt of a json message, one can create a root class:

    dynamic root = MapList(jsonString);
    // Allows also a direct MapList(jsonStructure)

*( this polymorphism of constructor is hand made : the type of parameter
is checked in the MapList class)*

Once loaded, the getter are available, from root or from any level of
relay :

    if (root.store.bikes[1].color == "grey") ...   
    dynamic store =root.store;
    if (store.bikes[1].color == "grey") ...  
    dynamic bicycles = root.store.bikes;  
    if (bicycle[1].color == "grey") ... 

## Create data structure on the fly

    void main (){  
    dynamic root = MapList({});  
    root.name = "experiment one";  
    root.results = [];  
    root.results.add({"elapsed time": "15", "temperature":33.1});  
    root.results.add({"elapsed time": "30", "temperature":35.0});  
    assert(root.results[1].temperature == 35);  
    }

## Interpretation capacity
You can also use a String to access to data :

    var result = root.interpret("store.bikes[1].color");
    if (result == "grey") ... 

You can also use simple setters in a script :

    var script = "store.bikes[1].color = blue";
    root.interpret(script); 

And also create and assign a value in a script :

    store.interpret("bikes[0].battery = true ");

## Tiny interpreter
The goal is not to make a full interpreter , but only to be able to get
and set data .  
This leaves the package to a defined scope, while a full interpreter
will be done in another package, which one will use the accessors of
MapList.

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


