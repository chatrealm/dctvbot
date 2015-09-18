module DCTV
  module Plugins

    class CheckDCTV
      # Cinch plugin
      include Cinch::Plugin

      # Handler to respond to
      listen_to :check_dctv

      def initialize(*args)
        super

        # Already announced channels
        @already_announced = Array.new

        # Official channel live status
        @official_channel_live = false

        # Mark currently live channels as already announced
        update_dctv_status
        # @bot.assignedchannels.each do |channel|
        #   @already_announced << channel
        # end

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
        # Update assigned channels and official live status from dctv
        update_dctv_status
        # Clean already announced list of upcoming and live channels when their status has changed
        clean_announced_list
        # Check all currently assigned channels
        @bot.assignedchannels.each do |channel|
          # Skip announcements if official cahnnel is live
          next if @official_channel_live || @already_announced.include?(channel)
          # Announce/Update topic
          announce_channel(channel)
          # Add channel to list of already announced channels
          @already_announced << channel
        end

        @bot.debug "check_dctv handler complete."
      end

      private

        # Checks if channel is official
        def is_official(channel)
          channel['channel'] == 1
        end

        # Checks if channel is online
        def is_online(channel)
          channel['nowonline'] == "yes"
        end

        # Updates assignedchannels from dctv api
        def update_assignedchannels
          response = Net::HTTP.get_response(URI.parse('http://diamondclub.tv/api/channelsv2.php?v=3'))
          @bot.assignedchannels = JSON.parse(response.body)['assignedchannels']
        end

        # Refreshes official channel live status
        def update_official_live
          @official_live = false
          @bot.assignedchannels.each do |channel|
            @official_live = true if is_online(channel) && is_official(channel)
          end
        end

        # Triggers update methods for dctv status
        def update_dctv_status
          update_assignedchannels
          update_official_live
        end

        # Formats channel announcement message
        def get_announce_message(channel)
          # Extract the info we need crom channel object
          name        = channel['friendlyalias']
          description = channel['twitch_yt_description']
          url         = channel['urltoplayer']
          upcoming    = channel['yt_upcoming']
          # Set color formatted status
          status = Format(:white, :red, " LIVE ")
          status = Format(:black, :yellow, " UP NEXT ") if upcoming
          # Piece together message from available info
          msg  = "#{status} #{name}"
          msg += " - #{description}" unless description.empty?
          msg += " - #{url}" unless url.empty?
        end

        # Does channel live/upcoming announcement
        def announce_channel(channel)
          # Set announce message
          output = get_announce_message(channel)
          # Announce channel
          @bot.primary_channel.send(output)
          # Update topic, if channel is official
          update_channel_topic(output) if is_official(channel)
        end

        # Updates primary channel's topic from given title, preserving existing title after first "|"
        # Example: 'first | second | third' -> update_primary_channel_topic('apple') -> 'apple | second | third'
        def update_primary_channel_topic(title)
          # Get array of items between "|" characters
          topic_array = @bot.primary_channel.topic.split("|")
          # Remove first item
          topic_array.shift
          # Add new info to beginning of former title
          new_topic = title + " |" + topic_array.join("|")
          # Set primary channel topic
          @bot.primary_channel.topic = new_topic
        end

        def clean_announced_list
          # Remove formerly upcoming channels from announced channels list if no longer upcoming
          announced_upcoming = @already_announced.find_all { |aa| aa['yt_upcoming'] }
          announced_upcoming.each do |au|
            channel = @bot.assignedchannels.find { |ch| ch['streamid'] == au['streamid'] }
            unless channel.nil? || channel['yt_upcoming']
              @already_announced.delete(channel)
            end
          end

          # Remove offline channels from announced channels list
          @already_announced.each do |aa|
            @already_announced.delete(aa)
            @bot.assignedchannels.each do |ac|
              if aa['streamid'] == ac['streamid']
                @already_announced << ac
              end
            end
          end
        end
    end

  end
end
