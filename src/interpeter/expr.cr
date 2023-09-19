require "../parser/AST.cr";
require "./main.cr";
require"./values.cr"
require "./enviroments.cr";
require "math"

module Interpeter
  def eval_binary_expr(expr : Expr, env : Enviroment) : RuntimeVal
    expr = expr.as BinaryExpr;
    results : RuntimeVal = mk_NULL();
    lhs = evaluate(expr.left,env)
    rhs = evaluate(expr.right,env)

    if lhs.type != "num" || rhs.type != "num" 
     puts "excepted left hand of num and righ hand of num in binary expr\nat => line:#{expr.right.line}, colmun:#{expr.right.colmun}"
     return results;
    end

    lhs = lhs.as(NumVal); rhs = rhs.as(NumVal);
    case expr.operator 
      when "plus"
        results = mk_NUM(lhs.value + rhs.value);
      when "minus"
        results = mk_NUM(lhs.value - rhs.value);
      when "multiply"
        results = mk_NUM(lhs.value * rhs.value);
      when "divide"
        results = mk_NUM(lhs.value / rhs.value);
      when "power"
        results = mk_NUM(lhs.value ** rhs.value);
      else
        #.this shouldnt happen!
        puts "err"
    end
    return results
  end

  def eval_unary_expr(expr : UnaryExpr, env : Enviroment) : RuntimeVal
    rhs = evaluate(expr.right, env);

    if rhs.type != "num"
      puts "error excepted right hand side of type num in UnaryExpr\nat => line:#{expr.line}, colmun:#{expr.colmun}";
      return mk_NULL();
    end

    rhs = rhs.as(NumVal);
    results : RuntimeVal = mk_NUM(0);

    case expr.operator
    when '-'
      results = mk_NUM(-rhs.value);
    when '+'
      return mk_NUM(+rhs.value);
    when "root"
      return mk_NUM(Math.sqrt(rhs.value));
    else
      puts "err";
    end
    return results;
  end

  def eval_id(expr : IdExpr, env : Enviroment) : RuntimeVal
    return env.find_var(expr.symbol);
  end
end
