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

  puts data
  count += 1
  break if count > 2
end
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

As of Ruby 3, can define a one-liner method without using `end` keyword, example:

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

Left at 0:54
