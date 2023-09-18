enum Type
  By_kw
  Of_kw
  Unknown_kw
  Set_kw
  To_kw
  Operator
  Num
  Id
  OpenParen
  CloseParen
  Err
  EOF
end

struct Token
  getter type;
  getter value;
  getter line;
  getter colmun;
  def initialize(@type : Type, @value : String | Char, @line : Int32,@colmun : Int32) 
  end
end


struct Tokenizer
  @@code = [] of String
  def initialize(code : String) 
    @@code = code.chars;
  end

  @operators = [
    "plus",
    "minus",
    "multiply",
    "divide",
    "power"
  ]
  @keywords = [
    {name: "by", type: Type::By_kw},
    {name: "of", type: Type::Of_kw},
    {name: "set", type: Type::Set_kw},
    {name: "to", type: Type::To_kw}
  ]
  def code
    @@code
  end
  @@line = 1;
  @@colmun = 0;
  @current_token : Token = Token.new(Type::Err, "unknown", @@line, @@colmun);
  getter current_token

  def add(type : Type, value : String | Char) 
    token = Token.new(type,value,@@line, @@colmun) 
    @current_token = token;
  end

  def isOperator(x) 
    return @operators.includes?(x);
  end


  def isKeyword(x)
    results = false
      @keywords.each do |keyword|
        results = keyword.[:name] == x;
        if results
          break;
        end
      end
    return results;
  end

  def getKeyword(x) 
    results = Type:: Unknown_kw

    @keywords.each do |keyword|
      if keyword[:name] == x
        results = keyword[:type]
        break;
      end
    end
    return results;
  end



  def isAllowedId(x)
    # latin only
    return !isSkippableChar(x) && x.upcase != x.downcase;
  end
  def isNum(x) 
    return "01234.56789".includes? x;
  end

  def isSkippableChar(x)
    return " ;".includes?(x) || x == "\t";
  end
  
  def take()
    @@colmun += 1;
    return @@code.shift();
  end
  
  def getLine() 
    if @@code[0] == "\n" 
      @@line += 1;
      @@colmun = 0;
      take
      return true;
    end
    return false;
  end

  def tokenize() 
    #this is desinged to only give one token!

    while @@code.size > 0 && isSkippableChar(@@code[0])
      take
    end
    if @@code.size <= 0
      add(Type::EOF, "<EOF>");
      return @current_token;
    end

    case @@code[0]
    # numbers!
    when '0','1','2','3','4','5','6','7', '8', '9'
      res : String = "";
      # to make a number of multipli chars ex. instead of '1' we make '668,77' as a single number
      while @@code.size > 0 && isNum(@@code[0])
        res += take
      end
      add(Type::Num, res)
    when '('
      add(Type::OpenParen, take)
    when ')'
      add(Type::CloseParen, take)
    else
      if getLine() 
      # what it does is definded in the getline func i did this to detecte lines in strings
      # does nothing
      elsif isAllowedId(@@code[0])
        ress : String = "";
        while @@code.size > 0 && isAllowedId(@@code[0]) 
          ress += take;
        end

        if isKeyword(ress)
          add(getKeyword(ress), ress)
        elsif isOperator(ress)
          add(Type::Operator, ress)
        else 
          add(Type::Id, ress)
        end
      else 
        puts "unknown char '#{@@code[0]}' at line:#{@@line},colmun:#{@@colmun}";
        add(Type::Err, take)
      end
    end
    return @current_token;
  end
end
