r = Ractor.new do
  name = receive
  puts "INSIDE RACTOR: Hello #{name}"
  name.upcase
end

r.send("John Doe")
name_transformed = r.take
puts "OUTSIDE RACTOR: #{name_transformed}"

r.take
