import 'package:map_list_dot/map_list_dot.dart';

/*
  token explicit names
  as tokenizer can't use an enum
 */
enum myLang {
  BOOLEAN,
  VARIABLE,
  DOT,
  JSON,
  LEFT_PARENTHESIS,
  RIGHT_PARENTHESIS,
  TABLE_INDEX,
  TABLE_STRING_INDEX,
  LEFT_BRACE,
  RIGHT_BRACE,
  SEMI_COLON,
  ADD,
  SUBTRACT,
  MULTIPLY,
  DIVIDE,
  POWER,
  EQUAL,
  NOT_EQUAL,
  GREATER_THAN,
  GREATER_OR_EQUALS,
  LESS_THAN,
  LESS_OR_EQUALS,
  ASSIGN,
  NUMBER,
  KEYWORD,
  STRING,
  IF,
  THEN,
  ELSE,
  COMMENT,
  LARGE_COMMENT,
}

/*
 for each vocabulary, construct a specific grammar
 For regex, use tripe quotes , but needs to double \ significant in regex
 except for \$ (which is $ in regex)
 */

class Grammar {
  Tokenizer _tokenizer;

  Tokenizer get tokenizer => _tokenizer;

  static const letters = '''[a-zA-Z][a-zA-Z0-9_]*''';
  // end of line, ; ) < > = space
  static const separators = '''(\$|[;\\)\\(\\s><=\.\\[])''';



  /*
   the order of regexp expression is significant
   as it must detect first reserved words before var
   like "if" before some "ifAvailable"
   */

  Grammar() {
    // how works regex vocabulary optional true by default
    bool caseSensitive = true;
    _tokenizer = new Tokenizer(caseSensitive: caseSensitive);
    // COMMENT as soon found a #, end of line is comment
    _tokenizer.add( myLang.COMMENT,'''#.*''');
    // LARGE_COMMENT
    // found on https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch07s06.html
    // seems that multiline has no effect at all.
    _tokenizer.add(myLang.LARGE_COMMENT,'''^\\/\\*[\\s\\S]*?\\*\\/''', multiLine: true); //^\/\*[\s\S]*\*\/

    // must take first vocabulary that can be confused with a variable name.
    _tokenizer.add(myLang.BOOLEAN, '''^(true|false)'''+separators );
    // betwween '' or "" don't care
    _tokenizer.add( myLang.STRING, '''^(['"](.*)['"])''');

    // keyword
    _tokenizer.add(myLang.IF, "^(if)"+separators );
    _tokenizer.add(myLang.ELSE,"^(else)"+separators);
    _tokenizer.add( myLang.THEN,"^(then)"+separators);
    /*
      variables : begin with a letter, followed by any combination of letters, digits,
      for compound name, will generate token for dot.
      token for index in table [10]
      string index in table ["zaza"]
   */
    _tokenizer.add( myLang.VARIABLE, '''^([a-zA-Z_][\\w\\d_]*)'''+separators);
    _tokenizer.add( myLang.DOT,'^\\.');
    _tokenizer.add(myLang.TABLE_INDEX,'^\\[\\d*\\]');
    _tokenizer.add(myLang.TABLE_STRING_INDEX,'^\\["\\w*"\\]');

    // number must be after table_index
    _tokenizer.add(myLang.NUMBER,'''^([-+]?[0-9]*\.?[0-9]+)''');

   /*

    */

    _tokenizer.add( myLang.JSON,'(^[{\\[].*[}\\]]\\s?)');


    // comparators
    _tokenizer.add(myLang.EQUAL, "^==");
    _tokenizer.add( myLang.NOT_EQUAL,"^!=");
    _tokenizer.add( myLang.GREATER_THAN, "^>");
    _tokenizer.add(myLang.GREATER_OR_EQUALS, "^>=");
    _tokenizer.add(myLang.LESS_THAN, "^<");
    _tokenizer.add(myLang.LESS_OR_EQUALS, "^<=" );

    // operators
    _tokenizer.add( myLang.ADD,"[+]");
    _tokenizer.add(myLang.SUBTRACT,"[-]");
    _tokenizer.add( myLang.MULTIPLY,"[*]");
    _tokenizer.add( myLang.DIVIDE, "[/]");
    _tokenizer.add( myLang.POWER, "\\^");
    _tokenizer.add( myLang.ASSIGN,"[=]",);


   // parenthesis are also regexp symbols, so escape them
    _tokenizer.add(myLang.LEFT_PARENTHESIS, "^\\(", );
    _tokenizer.add(myLang.RIGHT_PARENTHESIS,"^\\)", );
    _tokenizer.add( myLang.LEFT_BRACE, "^{");
    _tokenizer.add( myLang.RIGHT_BRACE,"^}",);
    _tokenizer.add(myLang.SEMI_COLON, "^;");
    // number before operators to take care of signed numbers like -123
  }
}
