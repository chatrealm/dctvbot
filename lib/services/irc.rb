# file: lib/services/irc.rb

require 'cinch'
require 'cinch/plugins/identify'

module Services
	class Irc

		def initialize(settings)
			configure_bot(settings)
		end

		def start
			@bot.start
		end

		def shutdown(message="")
			@bot.quit(message)
		end

		private

			attr_accessor :bot

			def configure_bot(settings)
				@bot  = Cinch::Bot.new do
					configure do |c|
						# Server Info
						c.server  = settings[:server]
						c.port    = settings[:port]

						# Bot User Info
						c.nick        = settings[:nick]
						c.user        = settings[:user]
						c.realname    = settings[:realname]
						c.channels    = settings[:channels]
						# c.delay_joins = 60

						# Load Up Plugins
						c.plugins.plugins = [
							Cinch::Plugins::Identify
						]

						# Set Plugin Options
						c.plugins.options = {
							Cinch::Plugins::Identify => {
					          type: :nickserv,
					          password: settings[:password]
					        }
						}
					end
				end
			end

	end
end
