require "./parser/parser.cr";
require "./interpeter/main.cr"
require "./parser/AST.cr";
require "./interpeter/enviroments.cr";
require "reply"
require "colorize"
require "option_parser"



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

opts : String | OptionParser= "unknown"

OptionParser.parse do |opt|
  opts = opt

  opt.banner = "The latinus programming language"
  opt.on "run", "Runs a file" do
    gave_file = false;
    opt.on "-f PATH", "--file=PATH", "File to run" do |path|
      gave_file = true;
      run(File.read(path));
    end

    opt.on "-h", "--help", "Displays help" { puts opt; exit 0; }
    
    opt.invalid_option do |flag|
      puts "unknown option '#{flag}'"
      puts opt
      exit 1
    end
    if ARGV.size < 2
      repl
    end
  end
  opt.on "-h", "--help","Displays help" { puts opt; exit 0;}
  opt.invalid_option do |flag|
    puts "unknown option '#{flag}'"
    puts opt
    exit 1
  end
  opt.missing_option do |option_flag|
    STDERR.puts "ERROR: #{option_flag} is missing something."
    STDERR.puts ""
    STDERR.puts opt
    exit(1)
  end
end

puts "error no args given!\nuse '{path/to/latinus} run' to enter repl, '{path/to/latinus} run -f {path/to/file}' to run from file\n#{opts}"

def repl
  puts "Welcome to The Latinus Repl!\nType 'exit' to exit!, Start typing to see the colors!"
  env = createEnv
  reader = AtonReader.new
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
end

def run(code)
  env = createEnv
  parser = Parser.new code;
  ast = parser.productAST
  ran = Interpeter.eval_program ast.as(Program), env
  puts ran.value
  exit
end
