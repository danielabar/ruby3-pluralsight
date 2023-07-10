def method_a(message, signature)
  puts "This is your message: #{message}"
  puts "This is your signature: #{signature}"
end

# `method_b` specifies forward arguments with triple dots,
# then passes these on to `method_a`
def method_b(name, ...)
  puts "Greetings #{name}!"
  method_a(...)
end

method_b("Mickey Mouse", "Have a great day", "abc123")
