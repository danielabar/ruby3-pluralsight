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
