# file: lib/services/dctv_api.rb

require 'active_support/time'
require 'digest'
require 'httparty'

module Services
  class DctvApi
    include HTTParty

    base_uri 'diamondclub.tv/api'

    CHANNELS_MAX_AGE = 5.seconds.to_i
    STATUS_MAX_AGE = 10.minutes.to_i

    def initialize(secs_pro, title_salt)
      @secs_pro = secs_pro
      @title_salt = title_salt

      @current_channels, @current_status = []
      @last_channels_update, @last_status_update = (Time.now - 30.seconds).to_i
    end

    def get_current_channels
      update_current_channels
      @current_channels
    end

    def get_current_status
      update_current_status
      @current_status
    end

    def set_second_screen(input, user_name)
      result = second_screen_request(input, user_name)
      result
    end

    def suggest_title(input, user_name)
      result = title_suggestion_request(input, user_name)
      result
    end

    def reset_title_suggestions
      result = reset_titles_request
      result
    end

    private

    attr_accessor :current_channels, :current_status,
                  :last_channels_update, :last_status_update, :secs_pro, :title_salt

    def update_current_channels
      if (Time.now - @last_channels_update).to_i > CHANNELS_MAX_AGE
        response = self.class.get('/channelsv2.php')
        @current_channels = JSON.parse(response.body)['assignedchannels']
        @last_channels_update = Time.now
      end
    end

    def update_current_status
      if (Time.now - @last_status_update).to_i > STATUS_MAX_AGE
        response = self.class.get('/statusv2.php')
        @current_status = JSON.parse(response.body)['livestreams']
        @last_status_update = Time.now
      end
    end

    def second_screen_request(input, user_name)
      if input =~ /^http/ || input == 'on' || input == 'off' || input == 'clear'
        options = { query: { url: input, pro: @secs_pro, user: user_name } }
        response = self.class.get('/secondscreen.php', options)
        response = "Command Sent. Response: #{response}"
      else
        response = 'Invalid Selection'
      end
      response
    end

    def title_suggestion_request(title, user_name)
      titlehash = Digest::MD5.hexdigest("#{user_name}#{@title_salt}#{title}")
      options = { query: {
        title: title,
        username: user_name,
        titlehash: titlehash
      } }
      response = self.class.get('/titlevotedo.php', options)
      response
    end

    def reset_titles_request
      options = { query: { reset: 'yes' } }
      response = self.class.get('/titlevotedo.php', options)
      response
    end
  end
end

# Example response
# [
#     {
#         "streamid": 411,
#         "channelname": "jurystone",
#         "friendlyalias": "JuRYstone",
#         "streamtype": "twitch",
#         "nowonline": "yes",
#         "alerts": true,
#         "twitch_currentgame": "Hearthstone: Heroes of Warcraft",
#         "twitch_yt_description": "TACO Training! Pushing it 2 the limit!",
#         "yt_upcoming": false,
#         "yt_liveurl": "",
#         "imageasset": "http://diamondclub.tv/i/730edee8ba83402041ccf29b8a7e5319ba1c736a.png",
#         "imageassethd": "",
#         "urltoplayer": "http://dctv.link/2",
#         "channel": 2
#     },
#     ...
# ]
