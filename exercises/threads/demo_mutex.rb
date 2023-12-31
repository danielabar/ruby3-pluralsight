require "benchmark"

time_elapsed = Benchmark.measure do
  c = 0
  m = Thread::Mutex.new

  fetch = proc { c }

  (1..10).map do |i|
    Thread.new do
      1_000_000.times { m.synchronize { c = fetch.call + 1 } }
      # temp debug
      puts "INSIDE THREAD #{i}: c = #{c}"
    end
  end.each(&:join)

  puts "Counter: #{c}"
end

puts "Time elapsed: #{time_elapsed.real}"
