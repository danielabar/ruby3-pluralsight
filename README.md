<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [What's New in Ruby 3](#whats-new-in-ruby-3)
  - [New Utility Methods](#new-utility-methods)
    - [Pattern Matching](#pattern-matching)
    - [Hash Filtering](#hash-filtering)
  - [Additional Method Features](#additional-method-features)
    - [Endless Methods](#endless-methods)
    - [Forward Arguments](#forward-arguments)
  - [Demo](#demo)
  - [Typesafe Programming](#typesafe-programming)
  - [RBS and Type Checking](#rbs-and-type-checking)
  - [Demo](#demo-1)
  - [Concurrency with Fibers and Ractors](#concurrency-with-fibers-and-ractors)
    - [Intro](#intro)
    - [Threads Demo](#threads-demo)
    - [Ractors](#ractors)
    - [Demo 1](#demo-1)
    - [Demo 2](#demo-2)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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

* Ruby is interpreted/dynamic language -> not compiled.
* Interpreted at runtime when code passed to Ruby interpreter.
* No way to compile before program runs to perform type checking.

## RBS and Type Checking

**RBS**

* RBS ships with Ruby 3 -> a language for defining types.
* File ending to `.rbs` to define Ruby classes/modules structure.
* RBS is also a tool for static type checking and analysis.
* Similar to header files in C/C++, helps developers to understand the *structure* of the class and method signatures, but does *not* define logic.

**Type Checking**

* A way to perform code checking prior to runtime.
* Popular type checking tool for Ruby is Sorbet, but it uses inline type definitions, whereas RBS uses a separate `.rbs` file.

RBS: Internal way to describe types in code, then you can use a type checker tool to evaluate type safeness of code before it gets interpreted.

## Demo

Consider a simple class that gets initialized with first and last names. How to ensure only strings get passed in to the constructor?

```ruby
class Person
  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end
end

# Valid
p1 = Person.new("John", "Doe")

# Invlalid, but Ruby will allow it
p2 = Person.new("John", 5)
```

Here's an RBS template that defines the types for the `Person` class:

```ruby
class Person
  # declare first_name attribute as String
  attr_reader first_name: String

  # declare last_name attribute as String
  attr_reader last_name: String

  # declare that constructor can only accept Strings for first and last names
  # declare that constructor is not expected to return anything (-> void)
  def initialize: (String first_name, String last_name) -> void
end
```

RBS file is similar to class, but *only* contains signatures and data type definitions.

RBS files are stored in a `sig` directory (signature).

Will use [steep](https://github.com/soutaro/steep) gem for type checking because its compatible with RBS.

Add to Gemfile:

```
gem 'steep'
```

Place `.rbs` files in `sig` directory.

From root of project, (one up from `sig` dir), run:

```
bundle exec steep init
```

Will have something like this:

```
.
├── Steepfile
├── person.rb
└── sig
    └── person.rbs
```

Update `Steepfile`, similar to `rakefile` with targets, tell it what directory contains code to be checked and where the signature files are:

```ruby
# Specify where to perform checks:
target :typesrbs do
  # Check current directory and all code within it.
  check "typesrbs/person.rb"
  # Where the signature files are located.
  signature "sig"
end
```

Run `bundle exec steep check` to run it, but for me, whole bunch of errors like this:

```
# Type checking files:

[Steep 1.4.0] [typecheck:typecheck@4] [background] Unexpected error: #<NoMethodError: undefined method `constant_entry' for #<RBS::Environment @declarations=(916 items) @class_decls=(307 items) @interface_decls=(26 items) @alias_decls=(20 items) @constant_decls=(571 items) @global_decls=(51 items)>

        entry = env.constant_entry(name)
                   ^^^^^^^^^^^^^^^
Did you mean?  constant_decls>
[Steep 1.4.0] [typecheck:typecheck@4] [background]   /Users/dbaron/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/steep-1.4.0/lib/steep/signature/validator.rb:394:in `validate_one_class'
[Steep 1.4.0] [typecheck:typecheck@4] [background]   /Users/dbaron/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:229:in `block (6 levels) in validate_signature'
[Steep 1.4.0] [typecheck:typecheck@4] [background]   /Users/dbaron/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/steep-1.4.0/lib/steep.rb:201:in `sample'
[Steep 1.4.0] [typecheck:typecheck@4] [background]   /Users/dbaron/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/steep-1.4.0/lib/steep/services/type_check_service.rb:226:in `block (5 levels) in validate_signature'
[Steep 1.4.0] [typecheck:typecheck@0] [background] Unexpected error: #<NameError: uninitialized constant RBS::AST::Declarations::TypeAlias

        when RBS::AST::Declarations::TypeAlias
                                   ^^^^^^^^^^^
Did you mean?  RBS::AST::TypeParam>
```

## Concurrency with Fibers and Ractors

### Intro

Historically, concurrent programming in Ruby has been done with threads, but threads (as compared to separate processes) tend to get messy wrt data synchronization. Multi-threaded code is non-deterministic, resulting in race conditions, and is to debug.

Before Ruby 3.x, multi-thread processing didn't support parallel execution on MRI, so even if you did get a complex multi-threaded program working, it still wasn't taking advantage of multiple cores.

Ractors (Ruby Actors) in Ruby 3.x solve this. Ractors support native multi-core processing in Ruby with elegant implementation.

Consider the following examples using threads:

```ruby
Thread.new do
  puts "Fetching from API..."
end

puts "Processing other stuff..."

# Output:
# Processing other stuff...
```

In the above example, no indication that the thread to fetch data from API did any work because execution of caller on the main thread has already resolved, without waiting for the created thread.

The example below solves this issue by calling the `join` method on the created thread, which will cause the main thread to wait for the created thread to finish execution and merge with the calling thread, before proceeding. i.e. the original caller will not resolve until the created thread has merged with it:

```ruby
t = Thread.new do
  puts "Fetching from API..."
end

puts "Processing other stuff..."
t.join

# Output:
# Processing other stuff...
# Fetching from API...
```

Complexities with threads:
* Need to create threads and keep track of them
* Need to make sure any created threads resolve with the main thread (i.e. original caller that spawned it)
* More code to manage, increasing chances of introducing bugs

### Threads Demo

Will show that threads are relatively slow, and how important it is to synchronize for sharing global values.

A demo program that creates an array of 10 threads, where each thread will update a shared `c` variable 1M times,  incrementing it by one.

```ruby
# Importing the 'Benchmark' module for measuring time
require "benchmark"

# Measure the time taken to execute the code inside the block
time_elapsed = Benchmark.measure do
  # Initialize a global variable 'c' with a value of 0
  # This represents the shared state of the threads we will create
  c = 0

  # Create a proc called 'fetch' that returns the value of 'c' when called
  fetch = proc { c }

  # Create an array of threads using 'map', where each thread increments 'c' one million times
  threads = (1..10).map do |_i|
    Thread.new do
      # Increment 'c' one million times by fetching its value with 'fetch' and adding 1
      1_000_000.times { c = fetch.call + 1 }
    end
  end

  # Wait for all threads to finish using 'join'
  threads.each(&:join)

  # Print the final value of 'c' after all the thread increments
  puts "Counter: #{c}"
end

# Print the time taken to execute the entire block of code
# `real` is the wall-clock time elapsed during the execution of the code block.
puts "Time elapsed: #{time_elapsed.real}"
```

Would expect incrementing 1,000,000 x 10 times = 10,000,000, but that's not what happens.

Example output:
```
Counter: 8078995
Time elapsed: 0.41333400000007714
```

Run again - time is similar but counter has different value:
```
Counter: 8086601
Time elapsed: 0.4157869999999093
```

Result of multi-threaded program is non-deterministic due to race condition of multiple threads accessing the same shared variable `c`, without any synchronization.

Solution is to use locking mechanism: [Mutex](https://docs.ruby-lang.org/en/3.2/Thread/Mutex.html). The idea is to wrap the thread logic that accesses a shared resource in a `synchronize` block. Then whichever thread is using the `c` reference will "lock" access to it so that no other threads can use it at the same time. The other threads will have to wait until the current thread is done with the shared resource.

```ruby
require "benchmark"

time_elapsed = Benchmark.measure do
  c = 0

  # Create a Mutex object named 'm' for synchronization
  m = Thread::Mutex.new

  fetch = proc { c }

  (1..10).map do |_i|
    Thread.new do
      # Perform a synchronized increment on 'c'
      # The 'm.synchronize' block ensures that only one thread can access the shared resource 'c' at a time,
      # preventing concurrent modifications and potential race conditions.
      1_000_000.times { m.synchronize { c = fetch.call + 1 } }
    end
  end.each(&:join)

  puts "Counter: #{c}"
end

puts "Time elapsed: #{time_elapsed.real}"
```

This time the output is as expected, but notice it takes about twice as long as the non-synchronized version earlier:
```
Counter: 10000000
Time elapsed: 0.9445350000000872
```

Running again get consistent counter result, with pretty much the same run time.

Synchronization creates performance overhead in a threaded environment.

Multi-threaded programming is more complicated - have to remember to synchronize (aka lock) access to shared resources, and it creates perf overhead.

### Ractors

Ractor: Ruby Actor, independent entity that has its own process and can run in a separate core. Can take advantage of multi-core processing hardware. Benefits:

* Each Ractor runs in its own process and in its own cpu core -> faster, more optimized than Threads. This makes Ruby 3 faster than Ruby 2.
* Ractors only have a single thread.
* No synchronization or joins required
* More intuitive to write parallel processing with Ractor based code as compared to Thread based code. No need for locking to handle shared state and joining.

Create a Ractor by creating a new instance of the [Ractor](https://docs.ruby-lang.org/en/3.2/Ractor.html) class, passing in a block:

```ruby
r = Ractor.new do
  # Logic of ractor goes here...
end
```

**Communication Methods**

`Ractor#send(x, move: false)`: Passes shareable objects (can be determined with static method `Ractor.shareable?(x)`)

Shareable objects - numbers, any mutable value.

Non shareable - strings - copied to ractor, must be frozen before it can become a shareable object.

`Ractor#take()`: Called outside to take a value from a ractor instance's process.

**Example with Data Communication**

The following ractor calls the `receive` method to accept a value from the main program, and assign it to a local variable `name`.

```ruby
r = Ractor.new do
  name = receive
  puts "INSIDE RACTOR: Hello #{name}"

  # This will be return value of ractor instance
  name.upcase
end

# This matches up with `receive` in Ractor `r`
r.send("John Doe")

# Note that after calling `take`, ractor instance `r` is terminated and no longer available
name_transformed = r.take
puts "OUTSIDE RACTOR: #{name_transformed}"

# Will error if you try to call it again
r.take
# <internal:ractor>:694:in `take': The outgoing-port is already closed (Ractor::ClosedError)
```

Outputs:

```
<internal:ractor>:267: warning: Ractor is experimental, and the behavior may change in future versions of Ruby! Also there are many implementation issues.
INSIDE RACTOR: Hello John Doe
OUTSIDE RACTOR: JOHN DOE
```

Ractors are thread-safe and support true multi-core parallel processing.

### Demo 1

Re-write thread counter code with Ractors:

```ruby
require "benchmark"

time_elapsed = Benchmark.measure do
  c = 0

  (1..10).map do |_i|
    r = Ractor.new do
      x = receive
      1_000_000.times { x += 1 }
    end

    r.send(c)
    c += r.take
  end

  puts "Counter: #{c}"
end

puts "Time elapsed: #{time_elapsed.real}"
```

Output shows it runs faster than thread based implementation, and still gets correct result:

```
Counter: 10000000
Time elapsed: 0.23488099999985934
```

### Demo 2

Update the joke app to use ractors to save each joke to a file. Want the file saving to happen in parallel with the main thread that is looping over jokes.

Ractor cannot reach outside itself to access variables, they must be passed in to the ractor. Will need to pass in filename to save the jokes to, and instance of the joke to be saved. Will pass in a hash:

```ruby
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
```

After running this, will have `jokes.txt` file created in the same directory from which the program was run. Example output:

```
Setup: I just got fired from my job at the keyboard factory., Punchline: They told me I wasn't putting in enough shifts.
Setup: What's the best thing about a Boolean?, Punchline: Even if you're wrong, you're only off by a bit.
```
