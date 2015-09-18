module Cinch
	module Plugins

		class CleverBot
			include Cinch::Plugin
			include Cinch::Extensions::Authentication

			match lambda { |m| /(.*)\s?@?#{m.bot.nick}[:,]?\s*(.*)/i }, use_prefix: false

			def initialize(*args)
				super
				@cleverbot = Cleverbot::Client.new
			end

			def execute(m, part_one, part_two=nil)
				return unless (@bot.cleverbot_enabled || authenticated?(m))
				response = @cleverbot.write "#{part_one} #{part_two}"
				m.reply response, true
			end
		end

	end
end
