require "json"
require "net/http"
require "debug"

class Joke
  attr_reader :type, :setup, :punchline

  def initialize(type:, setup:, punchline:)
    @type = type
    @setup = setup
    @punchline = punchline
  end

  # Endless methods
  def programming? = @type == "programming"
  def general? = @type == "general"

  # Utility method
  def tell_joke
    puts "Setup: #{@setup}"
    puts "Punchline: #{@punchline}"
  end
end

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)

  # Extract first (and only) element of the array,
  # and transform string keys to symbols
  data = JSON.parse(response)[0].transform_keys(&:to_sym)

  # Hash filtering to get rid of `id` attribute
  data = data.except(:id)

  # Instantiate a Joke instance from data hash
  joke = Joke.new(type: data[:type], setup: data[:setup], punchline: data[:punchline])

  # Use endless methods from joke class to take action based on joke type
  if joke.programming?
    puts "Got programming joke!"
    puts "---"
  elsif joke.general?
    puts "Got general joke!"
    puts "---"
  end

  joke.tell_joke

  count += 1
  break if count > 2
end
