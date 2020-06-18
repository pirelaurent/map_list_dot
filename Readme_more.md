---
  # A look inside
  ## classes
   **MapList** is a wrapper class around a unique *json*.  
   **MapListList** and **MapListMap** are two derived classes to take care of specific access.
#### about keyword *is*
A MapList cannot be checked by *'is Map'* or *'is List'*, but by **'is MapListMap'** or **'is MapListList'**  
*( one can always check (myMapList.json is Map) or (myMapList.json is List))*  
An attempt was made with *ListMixin* and *MapMixin* respectively on MapListList and MapListMap, but this leaves unresolved conflicts due to same inheritance from MapList.

```
root = MapList({"members": [ { "name": "Bourne", "age": 33 }]});
assert(root is MapList);
assert(root is MapListMap);
assert(root.json is Map);
assert(root.members is MapList);
assert(root.members is MapListList);
assert(root.members.json is List);
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

### interpreter
The interpreter works differently.  
With the help of some RegExp, it separates left hand side and right hand side around an = sign  
The rhs is transformed from string to internal data (ex: string true becomes bool true )
The lhs is first split around the dot (.) separating map entry names with their optionals indices if they are a List.  
The name in map is solved first , then indices are applied , then it loops on the next lhs entry up to the end.  
If there is a rhs, data is updated, otherwise data is replaced.

##### creating new data
When an unknown name in a map is found in the script:  
if the current script has a rhs, it creates an empty entry 'name : null' in the map, which will be replaced by rhs at the end.  
if its a get, it returns null.





 ** caution on path name **
The left path is the same in code or interpreter, without quotes :
```
book.name = "zaza"
book.set('name = "zaza"');
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
if (blackboard.exec('squad.members[2].powers.Radiation resistance) != null)...
```

####  Further work
The interpreter is reduced to getter and setter on stuctured data .  
A further work is to extend it to a larger usage.
