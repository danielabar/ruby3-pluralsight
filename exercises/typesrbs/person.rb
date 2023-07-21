class Person
  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end
end

Person.new("John", "Doe")
Person.new("John", 5)
