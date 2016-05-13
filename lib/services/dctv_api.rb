# file: lib/services/dctv_api.rb

require 'httparty'

module Services
	class DctvApi
		include HTTParty

		base_uri 'diamondclub.tv/api'

		CHANNELS_MAX_AGE = 10.seconds
		STATUS_MAX_AGE = 15.minutes

		def initialize
			@current_channels = nil
			@last_channels_update = 0

			@current_status = nil
			@last_status_update = 0
		end

		def get_current_channels
			update_current_channels
			return @current_channels
		end

		def get_current_status
			update_current_status
			return @current_status
		end

		def set_second_screen(input, user_name)
			result = second_screen_request(input, user_name)
			return result
		end

		private

			attr_accessor :current_channels, :current_status, :last_channels_update, :last_status_update

			def update_current_channels
				if Time.now - @last_channels_update > CHANNELS_MAX_AGE
					response = self.class.get('/channelsv2.php')
					@current_channels = JSON.parse(response.body)['assignedchannels']
					@last_channels_update = Time.now
				end
			end

			def update_current_status
				if Time.now - @last_status_update > STATUS_MAX_AGE
					response = self.class.get('/statusv2.php')
					@current_status = JSON.parse(response.body)['livestreams']
					@last_status_update = Time.now
				end
			end

			def second_screen_request(input, user_name)
				if input =~ /^http/ || input == "on" || input == "off" || input == "clear"
					options = { query: { url: input, pro: '4938827', user: user_name }}
					response = self.class.get('/secondscreen.php', options)
					response = "Command Sent. Response: #{response}"
				else
					response = "Invalid Selection"
				end
				return response
			end
	end
end

# Example response
# [
# 	{
# 		"streamid": 411,
# 		"channelname": "jurystone",
# 		"friendlyalias": "JuRYstone",
# 		"streamtype": "twitch",
# 		"nowonline": "yes",
# 		"alerts": true,
# 		"twitch_currentgame": "Hearthstone: Heroes of Warcraft",
# 		"twitch_yt_description": "TACO Training! Pushing it 2 the limit!",
# 		"yt_upcoming": false,
# 		"yt_liveurl": "",
# 		"imageasset": "http://diamondclub.tv/i/730edee8ba83402041ccf29b8a7e5319ba1c736a.png",
# 		"imageassethd": "",
# 		"urltoplayer": "http://dctv.link/2",
# 		"channel": 2
# 	},
# 	...
# ]
