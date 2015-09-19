require 'cleverbot'

module Cinch
	module Plugins

		class CleverBot
			include Cinch::Plugin

			match lambda { |m| /(.*)\s?@?#{m.bot.nick}[:,]?\s*(.*)/i }, use_prefix: false

			def execute(m, part_one, part_two=nil)
				response = @cleverbot.write "#{part_one} #{part_two}"
				m.reply response, true
			end
		end

	end
end
