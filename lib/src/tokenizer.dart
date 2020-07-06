/// catching a token is done by a regexp
/// TokenSearch is a couple (compiled regexp, unique name of token)

class TokenSearched {
  RegExp regexp;
  // set as var to use enum
  var tokenId;
  // pattern must be a compiled regexp
  // token is a free id
  TokenSearched(Pattern regexp, var tokenId) {
    this.regexp = regexp;
    this.tokenId = tokenId;
  }
}

/// when found a Token is created
/// with the part of source in text
/// associated with the named token from tokenSearched

class Token {
  var tokenId ;
  String text;

  Token(String text, var tokenId) {
    this.text = text;
    this.tokenId = tokenId;
  }

  String toString(){
    return ('${tail(tokenId)} \t $text ');
  }

  static String tail(anEnum){
    return anEnum.toString().split('.').last;
  }
}
/// Tokenizer is feeded with all useful TokenSearched
/// by several add of unitary elements ( order is important)
/// Can then tokenize a source code and return the list of identified token
///
class Tokenizer {
  List<TokenSearched> tokenSearched;
  List<Token> _tokens;
  get tokens => _tokens;
  bool caseSensitive;

  // constructor
  Tokenizer({caseSensitive:true}) {
    tokenSearched = <TokenSearched>[];
    _tokens = <Token>[];
    this.caseSensitive = caseSensitive;
  }

  /*
   allow multiline (mainly to trap large comments)
   add ^( to find only at the beginning of the string
   */
  void add( var tokenId,String regex, {multiLine:false}) {
    if  (regex.startsWith('^') == false) regex = "^(" + regex + ")";
    tokenSearched.add(
        // add ^( to find only at the beginning of the string
        new TokenSearched(RegExp(regex,caseSensitive: caseSensitive, multiLine: multiLine), tokenId));
  }

  void tokenize(String sourceCode) {
    //avoid blanks
    String s = sourceCode.trim();
    _tokens.clear();

    while (s != "") {
      var match = false;
      // loop on defined regexp until found 1 match
      for (TokenSearched info in tokenSearched) {
        RegExpMatch m = info.regexp.firstMatch(s);
        if (m != null) {
          match = true;
          // some regex extract a part inside the token to erase ("string")
          String tok = m.group(0);
          if (m.groupCount>=1) tok = m.group(1);
          _tokens.add(new Token(tok,info.tokenId, ));
          //clean up the found token
          s= s.replaceFirst(tok, "").trim();
          print('PLA83:${_tokens.last} $s');
          break;
        }
      }
      // must have found something to parse
      if (!match) throw new Exception("Unrecognized input: " + s);
    }
  }
}
// lg.ignore r"\s+