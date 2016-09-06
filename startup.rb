#!/usr/bin/env ruby

require_relative 'lib/dctvbot'

dctvbot = Dctvbot.new('config/config.yml')

mutex = Mutex.new
quit_signalled = ConditionVariable.new
signal_received = nil

# Handle signals QUIT (Ctrl-\), INT (Ctrl-C), and TERM (Kill Command)
%w(QUIT INT TERM).each do |signal_name|
  Signal.trap(signal_name) do |signal_number|
    signal_received = signal_number
    quit_signalled.signal
  end
end

Thread.new do
  mutex.synchronize do
    quit_signalled.wait(mutex) until signal_received
    dctvbot.shutdown("Shutdown signal received #{Signal.signame(signal_received)}")
  end
end

dctvbot.start
