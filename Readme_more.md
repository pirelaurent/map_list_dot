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

### how dot notation works in interpreter
First MapList analyse the string with some regex to separate Left Hand Side and (optionally) the Right Hand Side around an  = .
```
root.eval('a.b.c[2].d["price"] = 33'); // LHS = 'a.b.c[2].d["price"]', RHS = '33'
```
#### JsonNode
The access in interpreted don't reuse the noSuchMethod of MapList, but use a specific JsonNode class.  
A JsonNode instance is constructed with an initial json (the wrapped one of the MapList root) , the current path and the original path:  
    ```dynamic node = jsonNode(wrapped_json, leftHandSide, originalScript);```  
A JsonNode acts as a graph segment :  ***fromNode ---edge---> toNode***.  
When it is constructed, if recursively constructs successors that peels the path one step each, up to an empty one.  
As it is a constructor call, it returns itself and each caller set its segment as the received one. The final node pop up from the recursion.  
So, when the construction is done, the final segment is already in place and MapList, the initial caller, is at result.  
If something is wrong on the road trip in path, the JsonNode stops to chain and returns its current segment with a toNode null.  
An error in interpreter logs a Warning but don't throw an error.  
This can be changed looking for log.warning in the code.
#### Using JsonNode object segment
MapList returns the toNode as the final leaf reached.  
If it is a simple type (int, string, boolean, etc. ) MapList returns the value.  
If it is a Map or a List, MapList returns it wrapped in a new MapList (MapListList or MapListMap) in order to allow to be used by direct code through noSuchMethod.
#### creating new data
If there is a Right Hand Side, it is first converted from string to compatible types by  *adjustParam(string)*  

If fromNode is a Map the received result will be :
- **aMap---new key---> null**   if an unknown key is in path
- **aMap---key--->value**   if the key exists
MapList assign the result to the fromNode using the edge : ```fromNode[edge] = dataToSet```.

If fromNode is a List, the received result will be:
- **aList---index---> value of aList\[index]**  if index is valid
- **aList ---index---> null**  if index was wrong or out of range
- **aList --- 'last' ---> last value** of aList  if the keyword was used in path.

### common mistakes
Use the right path names  
The left path is the same in code or in interpreter, but surrounded with quotes in interpreter and **the path string starts after the root**:
``` dart
book.name = "zaza"
book.set('name = "zaza"');   // not 'book.name...
```
Don't confuse json key:value with a lhs = rhs  
*book.eval('"name":"zaza"')* will fail.  
Use **dart book.eval('name = "zaza"');** is ok  
or *book.eval('addAll({"name":"zaza"})')*  ok too.

### Blackboard usage
A blackboard is a shared place where you can pin any kind of information to share with others.  
You can use a first level MapList blackboard, responsible of interpretation of data.  
``` dart
dynamic blackboard = MapList();  
```
You can then fill in this blackboard with code or with string messages in a free way.
Every query on data will rely on the unique blackboard entry point:
``` dart
print(blackboard.eval('store.book[1].isbn'));
if (blackboard.eval('squad.members[2].powers.Radiation resistance') != null)...
```
####  Further work
This interpreter is limited to get and set data on structures made of maps, lists and native data.  
It's not a DSL with variables, it has no operators, no functions and so one. Be modest.
#### Planned enhancements
Enhance the grammar to help to discover early wrong syntax.
Will add comparison to prepare some rule engine.

