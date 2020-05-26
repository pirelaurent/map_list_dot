xpath on json

separators :  
 . one step  
 .. any steps

 store                  whole store
 store.book             all books  
 store.book[1]          second book
 store.book[1].author   the author of the second book




 store.book.author     all authors of a book








interpreter of a dot access "question.options[0].text"  
without creating intermediate classes

@ideas  
authorize wildcard in chain :  person[*].mail
add keyword .length .isNull
add collection (see if graphQl has a good syntax) : person[*].(mail||tel)

xpath equivalence ?
https://goessner.net/articles/JsonPath/

XPath	                JSONPath	Result
/store/book/author	    $.store.book[*].author	the authors of all books in the store
//author	            $..author	            all authors
/store/*	            $.store.*	            all things in store, which are some books and a red bicycle.
/store//price	        $.store..price	        the price of everything in the store.

//book[3]	            $..book[2]	            the third book
//book[last()]	        $..book[(@.length-1)]
                        $..book[-1:]	        the last book in order.
//book[position()<3]	$..book[0,1]
                        $..book[:2]	            the first two books
//book[isbn]	        $..book[?(@.isbn)]	    filter all books with isbn number
//book[price<10]	    $..book[?(@.price<10)]	filter all books cheapier than 10
//*	                    $..*	                all Elements in XML document. All members of JSON structure.



Unexpected character (at line 4, character 39)
  "birthDate": { "day": 15, "month": 09, "year": 1254