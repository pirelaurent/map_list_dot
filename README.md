# Simple xpath on json
## Motivation
A dart json is made of Maps, Lists and values.  
In code, it's easy to walk through the structure with respect of syntax:  
`someJson["store"]["book"][0]["author"];`  
If this is good at compile time when you know the structure, there is no
easy way to read the path later and apply it with some eval(...).

We plan to use a simplified xpath notation string like :  
`'store.book[0].author'`  
As we use a string definition, this can be used later in any kind of
dynamic interpreter.
## Raw static method in class JsonXpath
The method  
`static dynamic xpathOnJson(var jsonStep, String path)`  
take a json dart on entry with a path,  
is recursive, hence the term *jsonStep* and return the following :
### xpath mini syntax
| syntax                  | result                                  | sample              |    |
|:------------------------|:----------------------------------------|:--------------------|:---|
| store.bicycle.color     | value                                   | "red"               |    |
| store.book[1].author    | first book, single value                | "Evelyn Waugh"      |    |
| store.book[0..2].price  | price of the 3 first books. array       | [8.95, 12.99, 8.99] |    |
| store.book[1..1].author | single value. Force to be an array      | ["Evelyn Waugh"     |    |
| store.book.author       | authors from all books. array of values | ["A" ,"B"  , ...]   |    |
| store.book              | all books. array of books               | json                |    |
|                         |                                         |                     |    |


| Equivalence    | All books                       |
|:---------------|:--------------------------------|
| store.book     | simplest                        |
| store.book[]   | remember result could be a List |
| store.book[..] | \" \"                           |

(rare) case a Json starts as an anonymous collection :  
[{"name": "Polo" } ,  {"name": "Magellan"  }]

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
| store.book.isbn       | some book with no isbn | array of existing isbn |
| store.book.isbn10     | none of the book       | null                   |

#### with null
A global option can be set to change the behavior around null :  
`withNull = true;`  
 Some examples :

| question          | standard without null          | with null                                  |
|:------------------|:-------------------------------|:-------------------------------------------|
| store.book.isbn   | [0-553-21311-3, 0-395-19395-8] | [null, null, 0-553-21311-3, 0-395-19395-8] |
| store.book.isbn10 | null                           | [null, null, null, null]                   |

This can be useful is some case when you want to reconcile two lists,
books with price and books with isbn for example.

See unit tests for more examples.

# Mixin:\"with JsonXpath\"

Any class can declare the mixin with JsonXpath, as long it respect the
contract:
### to provide : dynamic toJson();
The class must return the json structure it want to expose.  
This is less powerful than a full reflection, but allow to choice
visibility and it works for class and simple json.

### to use : .xpath(String aPath)
Once the toJson method in place, the class inherits the method dynamic
xpath(String aPath).  
For example, assuming a class Person, made of a name, a structured
birthDate and a list of Contact, returning a json by toJson and
declaring with JsonXpath, the following is available :  
`print(who1.xpath('birthDate.year')); //1254`  
`print(who2.xpath('birthDate.month')); // 3`  
`print(who1.xpath('contacts[1].mail')); //'marco@venitia.com');`

## Wrapping any json in a JsonObject class
A convenient class JsonObject can hold a json internally and return it
by toJson().  
As this class declare the mixin so we can use xpath.  
Class provides two constructors :
- JsonObject.fromString(String message)
- JsonObject(this._json) with an already existing Json.

### sample
 Working with messages :  
` var x = JsonObject(message);  `  
` if (x.xpath('origin.id')=='myFriend')   `  
` print(x.xpath('origin.conversation.theme');`








