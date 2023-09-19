require "./values.cr"
require "../etc.cr"

def createEnv() : Interpeter::Enviroment
  env = Interpeter::Enviroment.new;

  env.declare_var("π", mk_NUM(Math::PI));
  env.declare_var("pi", mk_NUM(Math::PI));
  return env;
end
module Interpeter
class Enviroment
  @@line : Int32 = 1
  @@colmun : Int32 = 0

  @Vars : Hash(String | Char, RuntimeVal);
  def initialize()
    @Vars = Hash(String | Char, RuntimeVal).new;
  end
  def update
    @@line = Interpeter.line
    @@colmun = Interpeter.colmun
  end
  def declare_var(name : String | Char, value : RuntimeVal) : RuntimeVal
    update
    if @Vars.has_key?(name)
      error "error #{name} already exit";
      return mk_NULL;
    end
    
    @Vars[name] = value;
    return value;
  end

  def set_var(name : String | Char, value : RuntimeVal) : RuntimeVal
    update
    if !@Vars.has_key?(name)
      error "error #{name} doesnt exit";
      return mk_NULL;
    end
    
    @Vars[name] = value;
    return value;
  end


  def find_var(name : String | Char) : RuntimeVal
    update
    if !@Vars.has_key?(name)
      error "error #{name} doesnt exit!"
      return mk_NULL;
    end
    return @Vars[name];
  end
end
end
