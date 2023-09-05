require "./AST.cr";
require "./tokenizer.cr";


# this is a Partt parser!
struct Parser
  @Tokenizer : Tokenizer;

  # same as Tokenizer.current_token but its more fancy!
  @Token : Token;

  def initialize(code : String)
    @Tokenizer = Tokenizer.new code;
    # gets the first token
    @Token = @Tokenizer.tokenize
  end

  @@line = 1;
  @@colmun = 0;

  def update() 
    @@line = @Token.line
    @@colmun = @Token.colmun
  end
  
  # updates line and colmun info and returns current token
  def at()
    update;
    return @Token;
  end

  def notEOF()
    return at().type != Type::EOF
  end

  def take() 
    prev = @Token;
    @Token = @Tokenizer.tokenize;
    update

    return prev;
  end

  def except(correct_type : Type, msg : String)
    if at().type != correct_type
      puts msg + "\nat => line:#{at().line}, colmun:#{at().colmun}";
    end
    return take();
  end

  def productAST() : Program
    prog = Program.new;

    while notEOF 
      prog.body.push(parse_expr);
    end

    return prog;
  end

  # acts as a return to the first expr to parse
  def parse_expr() : Expr
    return parse_additive_expr;
  end
  

  # order is below:
  # expr
  # additive binary expr => +,-
  # multipactive binary expr => *,/,%
  # squared binary expr (idk what is it in english) => ^
  # unary expr =>, -1,+1, √1 (redirects to expr not to primary)
  # primary expr => finds nums ids & more;

  # handles add and minus exprs 1 + 1,1 - 1
  def parse_additive_expr() : Expr
    left : Expr = parse_multipicative_expr;
    while at().value == '+' || at().value == '-'
      operator = take().value;
      right = parse_multipicative_expr;

      left = BinaryExpr.new(left, right, operator, @@line, @@colmun);
    end
    return left;
  end


  def parse_multipicative_expr() : Expr
    left : Expr = parse_squared_expr;
    while at().value == '*' || at().value == '/' || at().value == '%'
      operator = take().value;
      
      right = parse_squared_expr;

      left = BinaryExpr.new(left, right, operator, @@line, @@colmun);
    end
    return left;
  end

  def parse_squared_expr() : Expr
    left : Expr = parse_primary_expr;
    while at().value == '^'
      take;
      right = parse_primary_expr;

      left = BinaryExpr.new(left, right, '^', @@line, @@colmun);
    end
    return left;
  end



  def parse_primary_expr() : Expr 
    case at().type 
      when Type::Num
        num = Num.new(take().value.to_f,@@line,@@colmun);
        return num;
      when Type::Id
        id = IdExpr.new(take().value, @@line, @@colmun);
        return id;
      when Type::OpenParen
        take; 
        expr = parse_expr;
        except(Type::CloseParen, "excepted ')'");
        return expr;
      when Type::Err
        take;

        # i dont think of making an error system for this!
        # make it yourself!
        return Null.new(@@line, @@colmun)
      when Type::Operator
        if at().value != '-' && at().value != '+' && at().value != '√'
            puts "error cannot use operator '#{at().value}' without vaild left hand side\nat => line:#{@@line}, colmun:#{@@colmun}";
            take;
            return Null.new(@@line, @@colmun);
        end
        operator = take.value;
        num = parse_expr;
        return UnaryExpr.new(num, operator, @@line, @@colmun);
      else
        puts "error unexcepted token found while parsing\ngot => type:#{at().type},value:#{at().value}"
        take;
        return Null.new(@@line, @@colmun);
    end
end
end
