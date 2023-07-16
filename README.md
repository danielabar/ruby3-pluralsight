# What's New in Ruby 3

My [course](https://www.pluralsight.com/courses/whats-new-ruby-3) notes learning Ruby 3 with Pluralsight.

Using Ruby v3.1.2

**Convenience for VS Code**

Install [Code Runner](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner) extension. Then from any Ruby file hit control + alt + n to run the file.

Add to `settings.json`:

```json
"code-runner.clearPreviousOutput": true,
"code-runner.runInTerminal": true,
```

## New Utility Methods

Demo app to illustrate the new language features: A simple command line app that fetches a random joke from a public API. Considerations include:

* How to validate structure of data returned from API?
* How to ensure proper data types when processing the API data?
* How to perform other things at the same time (parallel execution) to extend functionality of the app?

Example of joke API url: https://official-joke-api.appspot.com/jokes/programming/random

Example JSON response:

```json
[
  {
    "type": "programming",
    "setup": "A DHCP packet walks into a bar and asks for a beer.",
    "punchline": "Bartender says, \"here, but I’ll need that back in an hour!\"",
    "id": 375
  }
]
```

Returns an array of jokes, in this case, just one joke at index 0 is returned. Each joke has a type, setup, punchline, and id.

(Other allowed calls: Try /random_joke, /random_ten, /jokes/random, or /jokes/ten)

A first attempt Ruby program to retrieve jokes from this API:

```ruby
require "json"
require "net/http"

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  puts data.inspect
  count += 1
  break if count > 2
end
```

Example output:

```
[{"type"=>"programming", "setup"=>"A DHCP packet walks into a bar and asks for a beer.", "punchline"=>"Bartender says, \"here, but I’ll need that back in an hour!\"", "id"=>375}]
[{"type"=>"programming", "setup"=>"If you put a million monkeys at a million keyboards, one of them will eventually write a Java program", "punchline"=>"the rest of them will write Perl", "id"=>26}]
[{"type"=>"programming", "setup"=>"There are 10 types of people in this world...", "punchline"=>"Those who understand binary and those who don't", "id"=>29}]
```

During this course will make this program more readable and introduce new features of Ruby 3.

### Pattern Matching

Now have more ways to do object comparison in a structured way.

Example, consider the two hashes below that contain the same data, but differ in structure. First hash has key `fruits` as top level key within the main object. In second hash, `fruits` is a nested key in the `food` hash:

```ruby
option1 = {
  fruits: [
    "Apples",
    "Oranges",
    "Grapes"
  ]
}

option2 = {
  food: {
    fruits: [
      "Apples",
      "Oranges",
      "Grapes"
    ]
  }
}
```

Suppose a Ruby method needs to accept a hash of options and needs to support both of the above structures. The method needs to determine which structure its dealing with. This can be accomplished with `case` to match on the structure of the hash:

```ruby
def structure_matching(config)
  case config
  in { fruits: }
    puts "Option 1"
  in { food: { fruits: } }
    puts "Option 2"
  else
    puts "Invalid structure"
  end
end

option1 = {
  fruits: %w[Apples Oranges Grapes]
}

option2 = {
  food: {
    fruits: %w[Apples Oranges Grapes]
  }
}

structure_matching(option1) # Option 1
structure_matching(option2) # Option 2
```

Another example: Supply a user defined variable as placeholder for the value of a key, such as `position` in the example below.

BUT evaluation is sequential, so in the first two examples, it will match the first case:

```ruby
def value_matching(person)
  case person
  in { name:, role: position }
    puts "Any result with #{position}"
  in { name:, role: "CEO" }
    puts "Found CEO with #{name}"
  else
    puts "No match"
  end
end

person1 = {
  name: "Fred Flinstone",
  role: "Manager"
}

person2 = {
  name: "Barney Rubble",
  role: "CEO"
}

person3 = {
  name: "Wilma Flinstone",
  title: "Developer"
}

value_matching(person1) # Any result with Manager
value_matching(person2) # Any result with CEO
value_matching(person3) # No match
```

To have the CEO case matched, need to put that first:

```ruby
def value_matching(person)
  case person
  in { name:, role: "CEO" }
    puts "Found CEO with #{name}"
  in { name:, role: position }
    puts "Any result with #{position}"
  else
    puts "No match"
  end
end

person1 = {
  name: "Fred Flinstone",
  role: "Manager"
}

person2 = {
  name: "Barney Rubble",
  role: "CEO"
}

person3 = {
  name: "Wilma Flinstone",
  title: "Developer"
}

value_matching(person1) # Any result with Manager
value_matching(person2) # Found CEO with Barney Rubble
value_matching(person3) # No match
```

### Hash Filtering

New method on hash `except`. Simple example:

```ruby
options = {
  item_a: "A",
  item_b: "B"
}

# Extract a hash with all keys `except` item_a:
result = options.except(:item_a)

puts result
{ item_b: "B" }
# {:item_b=>"B"}
```

`except` method does *not* manipulate the current hash, rather, it creates a new hash with all entries from original hash, except the key passed in to the `except` method.

Slightly more complex example:

```ruby
person = {
  identification_number: "001",
  first_name: "John",
  last_name: "Doe",
  gender: "Male"
}

restricted_fields = %i[identification_number gender]
max_field_length = restricted_fields.map { |k| k.to_s.length }.max

restricted_fields.each do |k|
  person = person.except(k)
  pad_spaces = " " * (max_field_length - k.to_s.length)
  puts "Filtered #{k}, #{pad_spaces}person = #{person.inspect}"
end

puts "\nFinal person: #{person.inspect}"
```

Output:

```
Filtered identification_number, person = {:first_name=>"John", :last_name=>"Doe", :gender=>"Male"}
Filtered gender,                person = {:first_name=>"John", :last_name=>"Doe"}

Final person: {:first_name=>"John", :last_name=>"Doe"}
```

## Additional Method Features

### Endless Methods

As of Ruby 3, can define a one-liner method without using `end` keyword. Syntax is `def method_name = ...`. Notice the equals sign after method name, this indicates to Ruby that the entire method definition will appear on a single line with no `end` keyword.

Example, `active?` method is defined in `Member` class below:

```ruby
class Member
  attr_accessor :member_status, :insurance_status

  def initialize(member_status:, insurance_status:)
    @member_status = member_status
    @insurance_status = insurance_status
  end

  # Defines a one-liner method `active?`, notice there's no `end` keyword!
  def active? = @member_status == "active" && @insurance_status == "active"
end

john = Member.new(member_status: "active", insurance_status: "active")
fred = Member.new(member_status: "active", insurance_status: "cancelled")

puts "John is active: #{john.active?}" # true
puts "Fred is active: #{fred.active?}" # false
```

### Forward Arguments

A method that accepts "forward arguments" expresses this with `...` (triple dot) syntax.

As of Ruby 3, the `...` can be specified *after* the initial parameter in the method definition. This can then be passed on to other methods.

Example:

```ruby
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

# Usage: "Have a great day" and "abc123" become the forward arguments
method_b("Mickey Mouse", "Have a great day", "abc123")
# Greetings Mickey Mouse!
# This is your message: Have a great day
# This is your signature: abc123
```

## Demo

Integrate pattern matching, hash filtering, and endless methods into joke application.

Recall output from joke api is an array, for example, entering in browser: `https://official-joke-api.appspot.com/jokes/programming/random` returns something like:

```json
[
  {
    "type": "programming",
    "setup": "What’s the object-oriented way to become wealthy?",
    "punchline": "Inheritance.",
    "id": 378
  }
]
```

Initial version of joke program:

```ruby
require "json"
require "net/http"

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  puts data.inspect
  count += 1
  break if count > 2
end
```

Array only has one element, the joke, so we can extract it with index 0:

```ruby
require "json"
require "net/http"

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)

  # extract first (and only) element of the array
  data = JSON.parse(response)[0]

  puts data
  count += 1
  break if count > 2
end
```

The joke hash in the array uses string keys rather than symbols. Use [transform_keys](https://docs.ruby-lang.org/en/3.2/Hash.html#method-i-transform_keys) method to transform the string keys to symbols:

```ruby
require "json"
require "net/http"

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)

  # extract first (and only) element of the array
  # transform string keys to symbols
  data = JSON.parse(response)[0].transform_keys(&:to_sym)

  puts data.inspect
  count += 1
  break if count > 2
end
```

Now that we have a proper hash with symbols, can use pattern matching on the joke type (except instructor is using `programming` in uri so will always get programming type jokes):

(Could also try https://official-joke-api.appspot.com/random_ten which returns array of 10 jokes of different types, although every time I tried it returns mostly `general` type, with maybe one `programming` type.)

```ruby
require "json"
require "net/http"

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)

  # Extract first (and only) element of the array,
  # and transform string keys to symbols
  data = JSON.parse(response)[0].transform_keys(&:to_sym)

  # Pattern matching in hash
  case data
  in { type: "programming" }
    puts "Got a programming joke"
  in { type: "general" }
    puts "Got a general joke"
  end

  puts data.inspect
  count += 1
  break if count > 2
end
```

Use hash filtering to get rid of joke id:

```ruby
require "json"
require "net/http"

url = "https://official-joke-api.appspot.com/jokes/programming/random"
uri = URI(url)

count = 0

loop do
  response = Net::HTTP.get(uri)

  # Extract first (and only) element of the array,
  # and transform string keys to symbols
  data = JSON.parse(response)[0].transform_keys(&:to_sym)

  # Pattern matching in hash
  case data
  in { type: "programming" }
    puts "Got a programming joke"
  in { type: "general" }
    puts "Got a general joke"
  end

  # Hash filtering to get rid of `id` attribute
  data = data.except(:id)

  puts data.inspect
  count += 1
  break if count > 2
end
```

To demonstrate endless methods, create a `Joke` class to encapsulate the data:

```ruby
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
  puts data.inspect

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

  count += 1
  break if count > 2
end
```

Add utility method `tell_joke` to `Joke` class:

```ruby
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
```

## Typesafe Programming

Will learn how to use RBS to define class with types.

**Dynamically typed**

Variable can accept any value without knowing its data type in advance, and it can change its data type dynamically at runtime, based on what it gets assigned.

```
# a is currently an integer due to assignment of 1
a = 1

# b is currently a string due to assignment of "foo"
b = "foo"

# what is c? cannot add int and string
# Ruby: String can't be coerced into Integer (TypeError)
# Javascript allows this and will assign 1foo to c
c = a + b
```

**Statically typed**

Eg: Java. Data type must be defined when declaring the variable, *before* any value can be assigned. Compiler can determine if allowed values are being assigned.

```
int a = 1
string b = "foo"
# Compiler would produce a type mismatch error
int c = a + b
```

Left at 2:47
