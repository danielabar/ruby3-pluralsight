require "json"
require "net/http"
require "debug"

# Joke class
class Joke
  attr_reader :type, :setup, :punchline

  def initialize(type:, setup:, punchline:)
    @type = type
    @setup = setup
    @punchline = punchline
  end

  # === NEW METHOD ADDED HERE ===
  def extract_joke
    "Setup: #{@setup}, Punchline: #{@punchline}"
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

# Main program to loop over several jokes and process them
url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

# === NEW: SAVE JOKES TO A FILE
filename = "jokes.txt"

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

  # === NEW RACTOR BASED CODE HERE TO SAVE JOKE TO FILE IN PARALLEL ===
  r = Ractor.new do
    # Caller passes in a hash containing filename and joke
    d = receive

    # Extract variables we need from the hash
    f_ref = d[:filename]
    j_ref = d[:joke]

    # Check whether we should append to existing file or write to new file
    mode = File.exist?(f_ref) ? "a" : "w"
    File.open(f_ref, mode) do |f|
      f.write("#{j_ref.extract_joke}\n")
    end
  end

  # Communicate data into the Ractor
  r.send({ filename:, joke: })

  joke.tell_joke

  count += 1
  break if count > 2
end
