t = Thread.new do
  puts "Fetching from API..."
end

puts "Processing other stuff..."
t.join

# Output:
# Processing other stuff...
# Fetching from API...
