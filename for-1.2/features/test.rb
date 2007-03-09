begin
 output = `cat README`
 puts output
rescue => e
 puts e.message
end