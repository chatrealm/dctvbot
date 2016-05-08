# file: lib/services/irc.rb

require 'cinch'
require 'cinch/plugins/identify'

module Services
	class Irc

		def initialize
			configure_bot
		end

		def start
			@bot.start
		end

		def shutdown(message="")
			@bot.quit(message)
		end

		private

			attr_accessor :bot

			def configure_bot
				@bot  = Cinch::Bot.new do
					configure do |c|
						# Server Info
						c.server  = 'irc.chatrealm.net'
						c.port    = '6667'

						# Bot User Info
						c.nick        = 'testbot'
						c.user        = 'Cinch'
						c.realname    = 'Test Bot'
						c.channels    = ['#testbot']
						# c.delay_joins = 60

						# Load Up Plugins
						c.plugins.plugins = [
							Cinch::Plugins::Identify
						]

						# Set Plugin Options
						c.plugins.options = {
							Cinch::Plugins::Identify => {
					          type: :nickserv,
					          password: 'testeeng'
					        }
						}
					end
				end
			end

	end
end
