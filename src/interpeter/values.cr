abstract class RuntimeVal 
  @type : String = "";
  getter type;
end


class NumVal < RuntimeVal
  @type = "num";
  @value : Int32 | Int64 | Float32 | Float64
  def initialize(value : Int | Float32 | Float64) 
    @value = value;
  end
  getter value;
end

class StrVal < RuntimeVal
  @type = "str";
  def initialize(@value : String | Char) 
  end
  getter value;
end

class NullVal < RuntimeVal
  @type = "null"
  @value : Nil;
  def initialize()
    @value = nil;
  end
  getter value;
end

def mk_NULL() 
  return NullVal.new;
end

def mk_NUM(val : Int | Float64 | Float32) 
  return NumVal.new(val)
end

def mk_STR(val : String | Char) 
  return StrVal.new(val)
end

