require "./AST.cr"
require "./tokenizer.cr"
require "../etc.cr" # error macro

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
      error(msg);
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
    return parse_assigment_expr;
  end
  

  # order is below:
  # expr
  # assigment expr
  # var creation
  # additive binary expr => +,-
  # multipactive binary expr => *,/,%
  # squared binary expr (idk what is it in english) => ^
  # call
  # member
  # unary expr =>, -1,+1, √1 (redirects to expr not to primary)
  # primary expr => finds nums ids & more;
  def parse_assigment_expr : Expr
    left = parse_var_creation;
    if at().type == Type::To_kw
      take;
      if left.type != NodeType::Id
        error("excepted an id in assigment expr");
        return Unknown.new @@line, @@colmun;
      end
      name = (left.as IdExpr).symbol
      value = parse_var_creation;

      return AssigmentExpr.new name, value, @@line, @@colmun;
    else
      return left;
    end
  end
  def parse_var_creation : Expr
    if at().type == Type::Set_kw
      take;
      name = except(Type::Id,"excepted an id with var name").value
      except(Type::To_kw, "excepted 'to' keyword")

      value = parse_expr;

      return VarCreationExpr.new name,value,@@line,@@colmun;
    else
      return parse_additive_expr
    end
  end

  # handles add and minus exprs 1 + 1,1 - 1
  def parse_additive_expr() : Expr
    left : Expr = parse_multipicative_expr;
    while at().value == "plus" || at().value == "minus"
      operator = take().value;
      right = parse_multipicative_expr;

      left = BinaryExpr.new(left, right, operator, @@line, @@colmun);
    end
    return left;
  end


  def parse_multipicative_expr() : Expr
    left : Expr = parse_squared_expr;
    while at().value == "multiply" || at().value == "divide" || at().value == "modul"
      operator = take().value;
      except(Type::By_kw, "excepted 'multiply by' or 'divide by', etc")
      right = parse_squared_expr;

      left = BinaryExpr.new(left, right, operator, @@line, @@colmun);
    end
    return left;
  end

  def parse_squared_expr() : Expr
    left : Expr = parse_call_member_expr;
    while at().value == "power"
      take;
      except(Type::Of_kw, "excepted 'power of'");
      right = parse_call_member_expr;

      left = BinaryExpr.new(left, right, "power", @@line, @@colmun);
    end
    return left;
  end
  

  def parse_call_member_expr : Expr
    member = parse_member_expr
    if at().type == Type::Start
      return parse_call_expr(member);
    end

    return member;
  end

  def parse_call_expr(call : Expr?) 
    if call
      expr = CallExpr.new call, parse_args, @@line, @@colmun;

      if at().type == Type::Start
        expr = parse_call_expr(expr);
      end
      return expr;
    else
      left = parse_primary_expr;
      if at().type == Type::Start
        return parse_call_expr(left);
      end
      return left;
    end
  end

  def parse_member_expr : Expr
    left = parse_call_expr nil;


    while notEOF && (at().type == Type::Point || at().type == Type::OpenBracket)
      op = take;
      pproperty : Expr;
      isIndexed : Bool = false; # => obj[index_property] || obj->property

      if op.type == Type::Point
        isIndexed = false;
        pproperty = parse_expr;
        if pproperty.type != NodeType::Id
          error "excepted property of id obj->property"
        end
      else
        isIndexed = true;
        pproperty = parse_expr;

        except(Type::CloseBracket, "excepted ']'")
      end

      left = MemberExpr.new left, pproperty, isIndexed, @@line, @@colmun
    end

    return left;
  end
  
  def parse_args : Array(Expr)
    except(Type::Start, "excepted start of args '-'");

    args = [] of Expr

    if at().type != Type::Dot
      args = parse_items
    end

    except(Type::Dot, "excepted '.' to end args");
    return args;
  end
  
  def parse_items : Array(Expr)
    items = [] of Expr
    items.push parse_assigment_expr

    while at().type == Type::Comma
      take;
      items.push parse_assigment_expr
    end
    return items;
  end

  def parse_primary_expr() : Expr 
    case at().type 
      when Type::Num
        num = Num.new(take().value.to_f,@@line,@@colmun);
        return num;
      when Type::Str
        str = Str.new(take().value,@@line,@@colmun);
        return str;
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
        return Unknown.new(@@line, @@colmun)
      when Type::Operator
        if at().value != '-' && at().value != '+' && at().value != "root"
            error "error cannot use operator '#{at().value}' without vaild left hand side";
            take;
            return Unknown.new(@@line, @@colmun);
        end
        operator = take.value;
        num = parse_expr;
        return UnaryExpr.new(num, operator, @@line, @@colmun);
      else
        error "error unexcepted token found while parsing\ngot => type:#{at().type},value:#{at().value}"
        take;
        return Unknown.new(@@line, @@colmun);
    end
end
end
