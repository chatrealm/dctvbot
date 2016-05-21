# file: lib/cinch/plugins/dctv_status.rb

require 'cinch'
require 'cinch/extensions/authentication'

module Cinch
	module Plugins

		class DctvStatus
			include Cinch::Plugin
			include Cinch::Extensions::Authentication

			match(/now\s?\-?(v?)/, method: :now)

			def initialize(*args)
				super
				@dctv_api = config[:dctv_api]
			end

			def now(m, flag=nil)
				current_channels = @dctv_api.get_current_channels
				output = ""
				current_channels.sort_by!{ |c| c['channel'] }.each do |channel|
					unless channel['yt_upcoming']
						output += "Ch. #{channel['channel']}"
						output += " - #{channel['friendlyalias']}"
						output += " - #{channel['twitch_yt_description']}" unless channel['twitch_yt_description'].blank?
						output += " - #{channel['urltoplayer']}\n"
					end
				end
				output = "Nothing is currently live" if current_channels.count == 0
				flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
			end
		end

	end
end
