options = {
  item_a: "A",
  item_b: "B"
}

result = options.except(:item_a)

puts result
{ item_b: "B" }
# {:item_b=>"B"}
