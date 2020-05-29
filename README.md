# Simple xpath on json
## Motivation
A dart json is made of Maps, Lists and values.  
In code, it's quite easy to walk through the structure with respect of syntax:  
    someJson["store"]["book"][0]["author"];  
If this is good at compile time when you know the structure, there is no
easy way to read the path later and apply it.    
You have no interpreter to read such a String and apply it to get data. 

We propose a simplified xpath notation string like :  
    *store.book[0].author*    
As we use a string definition, this can be used later in any kind of
dynamic interpreter.
## Raw static method in class JsonXpath
The following method do the job:

    static dynamic xpathOnJson(var jsonStep, String path)  
It takes a json on entry and a searched path.   
The method is recursive (hence the term *jsonStep*) and returns the following :
### xpath mini syntax
| syntax                  | result                                  | sample              |
|:------------------------|:----------------------------------------|:--------------------|
| store.bicycle.color     | value                                   | "red"               |
| store.book[1].author    | first book, single value                | "Evelyn Waugh"      |
| store.book[0..2].price  | price of the 3 first books: array       | [8.95, 12.99, 8.99] |
| store.book[1..1].author | single value. Force to be an array      | ["Evelyn Waugh"]    |
| store.book.author       | authors from all books. array of values | ["A" ,"B"  , ...]   |
| store.book              | all books. array of books               | json                |
| store.book[0..6].price |  price of the first books, up to 7. if less return less             |array


   
| equivalent syntax to get all books    |                       |
|:---------------|:--------------------------------|
| store.book     | simplest way                         |
| store.book[]   | help to remember that result could be a List |
| store.book[..] | help to remember that result could be a List with range                         |

#### Anonymous collection
In some (rare) case a valid Json can start as an anonymous collection   
    *\[ {"name": "Polo" } ,  {"name": "Magellan"  } \]*    
In this case, there is no name at the beginning of the structure.

| syntax      | result | sample              |
|:------------|:-------|:--------------------|
| [1].name    | value  | "Magellan"          |
| [0..1].name | array  | ["Polo","Magellan"] |
| [].name     | array  | ["Polo","Magellan"] |
| .name       | array  | ["Polo","Magellan"] |


### null value & missing data
By default, the extractor don't hold back missing values in Lists.  
The following happens:

| sample                | problem                | result                 |
|:----------------------|:-----------------------|:-----------------------|
| store.bicycle.height  | unknown property       | null                   |
| store.book[37].author | out of range           | null                   |
| store.book[9..12]     | beginning out of range     | null|
| store.book.isbn       | some book with isbn, some without | array of existing isbn |
| store.book.isbn10     | none of the book       | null                   |

#### Option : JsonXpath.withNull
A global option can be set to change the behavior around null :
  
    JsonXpath.withNull = false;  // the default    
    JsonXpath.withNull = true;  // returns also the null   
 Some examples :

| question          | standard without null          | with null                                  |
|:------------------|:-------------------------------|:-------------------------------------------|
| store.book.isbn   | [0-553-21311-3, 0-395-19395-8] | [null, null, 0-553-21311-3, 0-395-19395-8] |
| store.book.isbn10 | null                           | [null, null, null, null]                   |

This can be useful is some case when you want to reconcile two lists,books with price and books with isbn for example.   
 Results have the same number and same order of entries.   
See unit tests for more examples.

# Mixin for any class: \"with JsonXpath\"

Any class can declare the mixin with JsonXpath, as long it respect the
following contract:
### Provides a toJson() method
The class must return the json structure it want to expose (and only what it wants to expose).  
This is less powerful than a full reflection, but allow to choice
exposed data.    
Returning a json allows to work with class as with any simple json.

### myObject.xpath(String aPath)
Once the *toJson* method in place, the class inherits the dynamic method
*xpath(String aPath)*.  
##### Example:   
A class Person is made of a name, a structured birth_Date and a list 'contacts' of structured Contact.   
The class declare the mixin with JsonXpath and return data by its toJson method.   
The following is available : 
 
    print(who1.xpath('birth_Date.year')); //1254 
    print(who2.xpath('birth_Date.month')); // 3  
    print(who1.xpath('contacts[1].mail')); //'marco@venitia.com');

# Wrapping any json in a JsonObject class
A convenient class *JsonObject* can hold a json internally and return it
by *toJson()*.  
As this class declare the mixin, it can use *xpath.* notation.  
Class provides two constructors :
- *JsonObject.fromString(String message)*
- *JsonObject(this._json)*    with an already existing Json.

### Sample
 Working with text messages (structured) :
    
    var x = JsonObject.fromString(message); //decode text message in json. wrap in a class   
    if (x.xpath('origin.id')=='myFriend') print(x.xpath('origin.conversation.theme');    
As xpath can return a subtree, one can make it again a JsonObject and continue (see quiz example) : 

    var question = JsonObject( aShow.xpath('show.videos[2].questions[0]'));       
    print( question.xpath('name'));        
    print( question.xpath('options.answer'));        

## Working with Yaml
 You can use *xpath* on a Yaml loaded with the dart yaml package.  
 The *store_test* shows a small example, *quiz_test* a larger one.  
 The Yaml package uses read-only specific *YamlMap* and *YamlList*.  
 As they respond to *is List* or *is Map*, xpath works directly on the yaml structure.    
 #### warning
 Remember that no modification is allowed on a yaml structure in memory. This can be an issue.  
 Waiting for a more standard yaml package, for the day you can allways reparse a yaml in standard json by :    
    
    var xJson = json.decode(json.encode(xYaml));

 # Status
 This package was designed for a simple use and provides only a small part of xpath equivalence.  
 We do not plan a better coverage.      
  

 HTH
 

