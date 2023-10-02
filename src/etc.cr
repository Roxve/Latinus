require "colorize"

macro dump(obj)
  {{obj}}.inspect
end

macro error(msg)
  puts ({{msg}} + "\nat => line:#{@@line}, colmun:#{@@colmun}").colorize(:red)
end
