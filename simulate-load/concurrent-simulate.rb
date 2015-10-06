#!/usr/bin/env ruby

require 'celluloid/current'
require 'celluloid/io'
require 'http'

class WebWorker

  include Celluloid

  def initialize(url)
    @url = url
    @prng = Random.new
  end

  def run(request_count = 1)
    request_count.times do
      #puts "Running request"
      HTTP.get(@url, :socket_class => Celluloid::IO::TCPSocket)
    end
  end

  def cycle
    loop do
      run
      delay_factor = @prng.rand(1000).to_f / 1000
      sleep delay_factor
    end
  end
end

class Manager
  include Celluloid

  def initialize(url, ticks = 1)
    @url = url
    @ticks = ticks
    @workers = []

    set_target

    every(@ticks) { run_tick}
  end

  def run_tick
    msg = ["Active: #{@workers.size}", "Target: #{@target_count}"]

    checkpoint = false
    if @workers.size == @target_count
      msg << "Resetting worker count"
      set_target
      checkpoint = true
    elsif @workers.size < @target_count
      msg << "Adding worker"
      worker = WebWorker.new(@url)
      worker.async.cycle
      @workers << worker
    elsif @workers.size > @target_count
      msg << "Removing worker"
      worker = @workers.pop
      worker.terminate
    end

    $stdout.print msg.join("\t") + "\r"
    $stdout.flush
  end

  def set_target
    @target_count = rand(100)
  end
end

url = "http://10.20.1.11/random"

$stdout.sync = true

manager = Manager.new(url)

sleep 20
puts "Completed after 20 seconds."

__END__

workers = []

$url = "http://10.20.1.11/random"

10.times do |i|
  puts "starting up worker #{i}"
  worker = WebWorker.new($url)
  worker.async.cycle
  workers << worker
  sleep 1
end

sleep 5

until workers.empty?
  puts "shutting down worker"

  worker = workers.shift
  worker.terminate
end
