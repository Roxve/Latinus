require "../parser/AST.cr"
require "./values.cr"
require "./enviroments.cr"
require "./main.cr"
module Interpeter
  def eval_var_creation(stmt : VarCreationExpr, env : Enviroment)
    value = evaluate stmt.value, env;
    return env.declare_var(stmt.name, value);
  end

  def eval_assigment(stmt : AssigmentExpr, env : Enviroment)
    value = evaluate stmt.value, env;
    return env.set_var(stmt.name, value);
  end
end
