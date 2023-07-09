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
