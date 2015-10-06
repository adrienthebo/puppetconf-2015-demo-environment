#!/usr/bin/env ruby

require 'typhoeus'

$mutex = Mutex.new
$counter = 0

$url = "http://10.20.1.11/random"

DELAY_MAX = 1_000
REQUEST_MAX = 50
WORKERS = 10

def run_thread
  prng = Random.new
  loop do
    delay = prng.rand(prng.rand(DELAY_MAX) + 1)
    sleep(delay.to_f / 1000)

    req_count = prng.rand(REQUEST_MAX)

    hydra = Typhoeus::Hydra.new(max_concurrency: 10)

    req_count.times { hydra.queue(Typhoeus::Request.new($url)) }

    hydra.run

    $mutex.synchronize { $counter += req_count }
  end
end


threads = Array.new(WORKERS, Thread.new { run_thread })

begin
  loop do
    before = $counter
    sleep 1
    after = $counter
    puts "#{$counter} requests #{after - before} requests/second"
    threads.each { |t| t.join(0.01) }
  end
rescue Interrupt
  puts
  threads.each(&:kill)
end


