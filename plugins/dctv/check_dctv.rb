# encoding: utf-8

module Plugins
  module DCTV
    class CheckDCTV

      include Cinch::Plugin

      listen_to :check_dctv

      def initialize(*args)
        super
        @official_live = false
        @official_soon = false

        # Set announced arrays so as to not re-announce what's already on
        @live_channels = Array.new
        @soon_channels = Array.new
        get_current_channels.each do |channel|
          @live_channels << channel if is_live channel
          @soon_channels << channel if is_upcoming channel
        end
      end

      def listen(m)
        current_channels = get_current_channels
        topic_was_updated = true if @official_live || @official_soon

        # Live Channels update
        @official_live = false
        @live_channels.each do |live_ch|
          still_live = false
          still_live = true if current_channels.any? { |channel| live_ch['streamid'] == channel['streamid'] && is_live(channel) }
          @live_channels.delete live_ch unless still_live
          @official_live = true if still_live && is_official(live_ch)
        end

        # Upcoming Channels update
        @official_soon = false
        @soon_channels.each do |soon_ch|
          still_soon = false
          still_soon = true if current_channels.any? { |channel| soon_ch['streamid'] == channel['streamid'] && is_upcoming(channel) }
          @soon_channels.delete soon_ch unless still_soon
          @official_soon = true if still_soon && is_official(soon_ch)
        end

        current_channels.each do |channel|
          next if (@live_channels + @soon_channels).include?(channel)
          next if @official_live
          @live_channels << channel if is_live channel
          @soon_channels << channel if is_upcoming channel
          msg = announce_message channel
          Channel(@bot.channels[0]).send msg
          if is_official channel
            update_topic msg if is_official channel
            @official_live = true if is_live channel
            @official_soon = true if is_upcoming channel
          end
        end

        update_topic " <>" if topic_was_updated && !(@official_live || @official_soon)

        (@live_channels + @soon_channels).each do |channel|
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
