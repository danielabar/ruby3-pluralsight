require "json"
require "net/http"

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  puts data
  count += 1
  break if count > 2
end
