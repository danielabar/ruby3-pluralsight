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
