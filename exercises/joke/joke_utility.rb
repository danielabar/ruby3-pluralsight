require "json"
require "net/http"
require "debug"

class Joke
  attr_reader :type, :setup, :punchline

  def initialize(type: , setup:, punchline:)
    @type = type
    @setup = setup
    @punchline = punchline
  end

  # Endless methods
  def programming? = @type == "programming"
  def general? = @type == "general "
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

  # WIP...
  # Instantiate a Joke instance from data hash
  joke = new Joke(type: data[:type], setup: data[:setup], punchline: data[:punchline])

  puts data.inspect
  count += 1
  break if count > 2
end
