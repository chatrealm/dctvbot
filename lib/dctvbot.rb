# file: lib/dctvbot.rb

require 'yaml'

require_relative 'services/irc'

class Dctvbot

	def initialize(config_file)
		# load config
		@config = load_config_file(config_file)

		@irc = Irc.new(@config[:irc])
	end

	def load_config_file(file)
		@config = YAML.load(File.open file)
	end

	def start
		@irc.start
	end

	def shutdown(message='Shutting down')
		@irc.shutdown(message)
	end

	private

		attr_accessor :config, :irc

end
