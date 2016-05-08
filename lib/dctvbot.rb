# file: lib/dctvbot.rb

require_relative 'services/irc'

class Dctvbot

	def initialize
		@irc = Services::Irc.new
	end

	def start
		@irc.start
	end

	def shutdown(message="")
		@irc.shutdown(message)
	end

	private

		attr_accessor :irc
end

mutex = Mutex.new
quit_signalled = ConditionVariable.new
signal_received = nil
dctvbot = Dctvbot.new

# Handle signals QUIT (Ctrl-\), INT (Ctrl-C), and TERM (Kill Command)
%w[QUIT INT TERM].each do |signal_name|
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
