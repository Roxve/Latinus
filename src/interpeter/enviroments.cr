require "./values.cr"

def createEnv() : Enviroment 
  env = Enviroment.new;

  env.declare_var("π", mk_NUM(Math::PI));
  env.declare_var("pi", mk_NUM(Math::PI));
  return env;
end

class Enviroment 
  @Vars : Hash(String | Char, RuntimeVal);
  def initialize()
    @Vars = Hash(String | Char, RuntimeVal).new;
  end
  
  def declare_var(name : String | Char, value : RuntimeVal) : RuntimeVal
    if @Vars.has_key?(name)
      puts "error #{name} already exit";
      return mk_NULL;
    end
    
    @Vars[name] = value;
    return value;
  end
  def find_var(name : String | Char) : RuntimeVal
    if !@Vars.has_key?(name)
      puts "error #{name} doesnt exit!"
      return mk_NULL;
    end
    return @Vars[name];
  end
end
