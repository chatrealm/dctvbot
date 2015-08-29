# encoding: utf-8

module Plugins
  class CheckDCTV

    include Cinch::Plugin

    listen_to :check_dctv

    def initialize(*args)
      super
      # Set announced arrays so as to not re-announce what's already on
      @live_channels = Array.new
      @soon_channels = Array.new
      get_current_channels.each do |channel|
        @live_channels << channel if is_live channel
        @soon_channels << channel if is_upcoming channel
      end
    end

    def listen(m)
      channels = get_current_channels

      channels.each do |channel|
        output = "Ch. #{channel['channel']} - #{channel['friendlyalias']}"
        output += " - Live" if is_live(channel)
        output += " - Upcoming" if is_upcoming(channel)
        @bot.log(output)
      end
    end

    private

      def get_current_channels
        response = Net::HTTP.get_response(URI.parse('http://diamondclub.tv/api/channelsv2.php?v=3'))
        return JSON.parse(response.body)['assignedchannels']
      end

      def is_live(channel)
        return channel['nowonline'] == 'yes' && !channel['yt_upcoming']
      end

      def is_upcoming(channel)
        return channel['nowonline'] == 'no' && channel['yt_upcoming']
      end

  end
end
