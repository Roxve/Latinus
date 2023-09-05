enum NodeType
  Expr
  Program
  BinaryExpr
  UnaryExpr
  Num
  Null
  Id
end


abstract class Expr
  @type : NodeType = NodeType::Expr;
  @line : Int32 = 1;
  @colmun : Int32 = 0;
  getter line;
  getter colmun;
  getter type;
end

# in this interpeter everything is an expr,
# because we dont need stmt like var creation
# we only need math!


class Program < Expr 
  @type = NodeType::Program;
  @body : Array(Expr) = [] of Expr;
  getter body;
  def initialize()
    @body = [] of Expr;
  end
end



class BinaryExpr < Expr
  @type = NodeType::BinaryExpr;
  def initialize(@left : Expr, @right : Expr, @operator : String | Char, line, colmun)
    @line = line;
    @colmun = colmun;
  end
  getter left;
  getter right;
  getter operator;
end

class UnaryExpr < Expr
  @type = NodeType::UnaryExpr;
  def initialize(@right : Expr, @operator : String | Char, @line, @colmun)
  end
  getter right;
  getter operator;
end



class Num < Expr
  @type = NodeType::Num;
  def initialize(@value : Float32 | Float64, line, colmun) 
    @line = line;
    @colmun = colmun;
  end
  getter value;
end


class Null < Expr
  @type = NodeType::Null;
  def initialize(line, colmun) 
    @line = line;
    @colmun = colmun
  end
end

class IdExpr < Expr
  @type = NodeType::Id;
  def initialize(@symbol : String | Char,@line, @colmun)
  end
  getter symbol;
end
