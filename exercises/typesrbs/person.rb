class Person
  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end
end

p1 = Person.new("John", "Doe")
p2 = Person.new("John", 5)
