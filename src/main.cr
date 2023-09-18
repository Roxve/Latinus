require "./parser/parser.cr";
require "./interpeter/main.cr"
require "./parser/AST.cr";
require "./interpeter/enviroments.cr";
require "reply"
require "colorize"

puts "Welcome to The Latinus Repl!\nType 'exit' to exit!, Start typing to see the colors!"


def isNum(str : String) 
  results : Bool = false;
  str.chars.each do |char|
    if "012345.6789π".includes? char
      results = true;
    else
      results = false;
    end
  end

  return results;
end

# my own custom reader!
class AtonReader < Reply::Reader
  def prompt(io : IO, line_number : Int32, color? : Bool) : Nil
    io.write(">> ".encode("UTF-8"));
  end
  # colorize as you type!
  def highlight(expression : String) : String
    # Highlight the expression
    if expression.upcase.includes? "EXIT"
      return expression.colorize(:red).to_s
    elsif isNum(expression)
      return expression.colorize(:yellow).to_s;
    elsif expression.size > 0 && " \t".includes? expression[expression.size - 1];
      return expression.colorize(:blue).to_s;
    elsif expression.upcase != expression.downcase
      return expression.colorize(:green).to_s
    else 
      return expression.colorize(:green).to_s;
    end
  end
end

reader = AtonReader.new
env = createEnv;

reader.read_loop do |code| 
  STDOUT.flush
  if code.upcase.includes? "EXIT"
    exit
  end
  
  parser = Parser.new(code);
  ast = parser.productAST;

  ran = Interpeter.eval_program(ast.as(Program), env);
  puts ran.value;
end
