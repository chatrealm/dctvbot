# file: lib/services/irc.rb

require 'cinch'
require 'cinch/plugins/identify'
require 'cinch/extensions/authentication'


module Services
	class Irc

		def initialize(settings)
			@bot = Cinch::Bot.new do
				configure do |c|
					# Server Info
					c.server	= settings[:server]
					c.port		= settings[:port]

					# Bot User Info
					c.nick			= settings[:nick]
					c.user			= settings[:user]
					c.realname		= settings[:realname]
					c.channels		= settings[:channels]
					# c.delay_joins	= 60

					# Authentication Extension Settings
				    c.authentication			= Cinch::Configuration::Authentication.new
				    c.authentication.strategy	= :channel_status
				    c.authentication.level		= :v

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

		def start
			@bot.start
		end

		def shutdown(message='Shutting down')
			@bot.quit(message)
		end

		private

			attr_accessor :bot
	end
end
