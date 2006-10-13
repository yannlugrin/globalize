# This is a script template I use when parsing data that I've
# copied'n'pasted from the web. Change it each time new data
# should be parsed...

File.read("_temp.dat").split(/$/) do |line| line.strip!
  next if line =~ /^#/ or line.empty?
  
  a,b,c = line.split(',').collect { |f| f.strip }
  
  puts "%3d | %-5s | %-30s" % [a.to_i, b, c]
end
