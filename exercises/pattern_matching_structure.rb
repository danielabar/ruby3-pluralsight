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
