# encoding: utf-8

module Plugins
  module DCTV
    class CheckDCTV

      include Cinch::Plugin

      listen_to :check_dctv

      def initialize(*args)
        super
        @official_live = false
        # Set announced arrays so as to not re-announce what's already on
        @announced_channels = Array.new
        get_current_channels.each do |channel|
          @announced_channels << channel
        end
      end

      def listen(m)
        current_channels = get_current_channels

        @announced_channels.each do |live_ch|
          still_live = false
          current_channels.each do |channel|
            if live_ch['streamid'] == channel['streamid'] && is_live(channel)
              still_live = true
              @announced_channels.delete live_ch
              @announced_channels << channel
            end
          end
          @announced_channels.delete live_ch unless still_live
        end

        if @official_live
          @official_live = false
          current_channels.each do |channel|
            @official_live = true if is_official(channel) && is_live(channel)
          end
          update_topic(" <>") unless @official_live
        end
        return if @official_live

        current_channels.each do |channel|
          next if @announced_channels.include?(channel)
          @announced_channels << channel
          msg = announce_message channel
          if is_official(channel) && is_live(channel)
            update_topic msg
            @official_live = true
          end
          Channel(@bot.channels[0]).send msg
        end

        @announced_channels.each do |channel|
          output = "Ch. #{channel['channel']} - #{channel['friendlyalias']}"
          output += " - Live" if is_live channel
          output += " - Upcoming" if is_upcoming channel
          @bot.log output
        end
      end

      private

        def get_current_channels
          response = Net::HTTP.get_response(URI.parse('http://diamondclub.tv/api/channelsv2.php?v=3'))
          return JSON.parse(response.body)['assignedchannels']
        end

        def update_topic(title)
          topic_array = Channel(@bot.channels[0]).topic.split("|")
          topic_array.shift
          new_topic = title + " |" + topic_array.join("|")
          Channel(@bot.channels[0]).topic = new_topic
        end

        def announce_message(channel)
          if is_live channel
            status = Format :white, :red, " LIVE "
          else
            status = Format :black, :yellow, " UP NEXT "
          end
          msg = "#{status} #{channel['friendlyalias']}"
          msg += " - #{channel['twitch_yt_description']}" unless channel['twitch_yt_description'].empty?
          msg += " - #{channel['urltoplayer']}"
          return msg
        end

        def is_official(channel)
          return channel['channel'] == 1
        end

        def is_live(channel)
          return channel['nowonline'] == 'yes' && !channel['yt_upcoming']
        end

        def is_upcoming(channel)
          return channel['nowonline'] == 'no' && channel['yt_upcoming']
        end

    end
  end
end
