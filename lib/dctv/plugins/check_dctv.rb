module DCTV
  module Plugins

    class CheckDCTV
      # Include Cinch stuff
      include Cinch::Plugin

      # Already announced channels
      attr_accessor :already_announced

      # Event the plugin responds to
      listen_to :check_dctv

      def initialize(*args)
        super

        @bot.update_dctv_status

        @already_announced = Array.new
        @bot.assignedchannels.each do |stream|
          @already_announced << stream
        end

        # @bot.assignedchannels = JSON.parse( '[
        #   {
        #     "streamid": 16,
        #     "channelname": "Frogpants_Scott",
        #     "friendlyalias": "Frogpants Studios",
        #     "streamtype": "twitch",
        #     "nowonline": "yes",
        #     "alerts": true,
        #     "twitch_currentgame": "",
        #     "twitch_yt_description": "Game Talkin!",
        #     "yt_upcoming": false,
        #     "yt_liveurl": "",
        #     "imageasset": "http://diamondclub.tv/i/ea96e36fe6008c793d05acef02d16e8c7927463e.png",
        #     "imageassethd": "",
        #     "urltoplayer": "http://dctv.link/2",
        #     "channel": 2
        #   }
        # ]')
      end

      # Executed on event trigger
      def listen(m)
        # Update assigned channels on dctv
        @bot.update_dctv_status

        # Remove formerly upcoming channels from announced channels list if no longer upcoming
        announced_upcoming = @already_announced.find_all { |aa| aa['yt_upcoming'] }
        announced_upcoming.each do |au|
          stream = @bot.assignedchannels.find { |st| st['streamid'] == au['streamid'] }
          @already_announced.delete(stream) unless stream.nil? || stream['yt_upcoming']
        end

        # Remove offline channels from announced channels list
        @already_announced.each do |aa|
          unless @bot.assignedchannels.any? { |ac| ac['streamid'] == aa['streamid'] }
            @already_announced.delete(aa)
          end
        end

        @bot.assignedchannels.each do |stream|
          # Skip announcements if official cahnnel is live
          next if @bot.official_live || @already_announced.include?(stream)
          # Announce/Update topic
          @bot.announce_stream(stream)
          # Add channel to list of already announced channels
          @already_announced << stream
        end

        @bot.debug "check_dctv event complete."
      end
    end

  end
end
