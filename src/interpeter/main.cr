require "../parser/AST.cr";
require "./values.cr";
require "./expr.cr"
require "./enviroments.cr";

module Interpeter 
  @@line = 1;
  @@colmun = 0;
  def self.eval_program(prog : Program, env : Enviroment)
    last : RuntimeVal = mk_NULL();
    prog.body.each do |expr| 
      last = evaluate(expr, env);
    end

    return last;
  end

  def self.evaluate(expr : Expr, env : Enviroment) : RuntimeVal 
    @@line = expr.line;
    @@colmun = expr.colmun; 
    last : RuntimeVal = mk_NULL();
    case expr.type
    when NodeType::Program
      last = eval_program(expr.as(Program), env);
    when NodeType::BinaryExpr
      last = eval_binary_expr(expr, env);
    when NodeType::UnaryExpr
      last = eval_unary_expr(expr.as(UnaryExpr), env);
    when NodeType::Num
      last = mk_NUM(expr.as(Num).value);
    when NodeType::Null
      last = mk_NULL();
    when NodeType::Id
      last = eval_id(expr.as(IdExpr), env);
    else
      last = mk_NULL();
    end
    return last;
  end
end
