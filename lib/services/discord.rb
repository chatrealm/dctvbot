# file: lib/services/discord.rb

require 'discord'

module Services
	class Discord

		attr_reader :bot

		def initialize
			configure_bot
			# @bot.run
		end

		private

			def configure_bot
				@bot = Discordrb::Bot.new(
					token: 'MTc0MTY3NzAyNjE5OTQ3MDA4.Cf-90A.i-SD5IbaNEkpXB4hcU1NP-OpeBQ',
					application_id: 174167571489095680)

				# bot.message(with_text: 'Ping!') do |event|
				# 	event.respond 'Pong!'
				# end
			end
	end
end
