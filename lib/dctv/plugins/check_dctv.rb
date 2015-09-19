module DCTV
  module Plugins

    class CheckDCTV
      # Cinch plugin
      include Cinch::Plugin
      # Handler to respond to
      listen_to :check_dctv

      def initialize(*args)
        super
        @@i = 0
        # Already announced channels
        @already_announced = Array.new
        # Official channel live status
        @official_live = false
        # Mark currently live channels as already announced
        update_assignedchannels
        @bot.assignedchannels.each do |channel|
          @already_announced << channel
        end
      end

      # Executed on event trigger
      def listen(m)
        # Update assigned channels from dctv
        update_assignedchannels#_debug
        @bot.debug "Assigned Channels from DCTV api:"
        @bot.assignedchannels.each do |channel|
          @bot.debug "#{channel['channel']}. #{channel['friendlyalias']} - #{is_online?(channel) ? 'Live' : 'Upcoming'}"
        end

        # Clean already announced list of upcoming and live channels when their status has changed
        refresh_announced_list
        @bot.debug "Already Live Channels:"
        @already_announced.each do |channel|
          @bot.debug "#{channel['channel']}. #{channel['friendlyalias']} - #{is_online?(channel) ? 'Live' : 'Upcoming'}"
        end

        # Check all currently assigned channels
        @bot.assignedchannels.each do |channel|
          # Skip announcements if official cahnnel is live
          next if @official_live || @already_announced.include?(channel)
          # Announce/Update topic
          announce_channel(channel)
          # Add channel to list of already announced channels
          @already_announced << channel
        end

        # Update official live status from dctv
        update_official_live
        @bot.debug "Official Live? #{@official_live}"

        @bot.debug "check_dctv handler complete."
      end

      private

        # Checks if channel is official
        def is_official?(channel)
          channel['channel'] == 1
        end

        # Checks if channel is online
        def is_online?(channel)
          channel['nowonline'] == "yes"
        end

        # Checks if channel is upcoming
        def is_upcoming?(channel)
          channel['yt_upcoming']
        end

        # Updates assignedchannels from dctv api
        def update_assignedchannels
          response = Net::HTTP.get_response(URI.parse('http://diamondclub.tv/api/channelsv2.php?v=3'))
          @bot.assignedchannels = JSON.parse(response.body)['assignedchannels']
        end

        # Updates assignedchannels from dctv api
        def update_assignedchannels_debug
          case @@i
          when 2..3
            @bot.assignedchannels = JSON.parse('[
              {
                "streamid": 300,
                "channelname": "DailyTechNewsShow",
                "friendlyalias": "DTNS",
                "streamtype": "youtube",
                "nowonline": "no",
                "alerts": true,
                "twitch_currentgame": "",
                "twitch_yt_description": "DTNS 2584 - with Erin Carson",
                "yt_upcoming": true,
                "yt_liveurl": "https://www.youtube.com/watch?v=ZjNjv959uUI",
                "imageasset": "http://diamondclub.tv/i/5f5c5ebe764eaf99143188b75a4e021a2b121883.png",
                "imageassethd": "",
                "urltoplayer": "http://dctv.link/1",
                "channel": 1
              }
            ]')
          when 4..5
            @bot.assignedchannels = JSON.parse('[
              {
                "streamid": 300,
                "channelname": "DailyTechNewsShow",
                "friendlyalias": "DTNS",
                "streamtype": "youtube",
                "nowonline": "yes",
                "alerts": true,
                "twitch_currentgame": "",
                "twitch_yt_description": "DTNS 2584 - with Erin Carson",
                "yt_upcoming": false,
                "yt_liveurl": "https://www.youtube.com/watch?v=ZjNjv959uUI",
                "imageasset": "http://diamondclub.tv/i/5f5c5ebe764eaf99143188b75a4e021a2b121883.png",
                "imageassethd": "",
                "urltoplayer": "http://dctv.link/1",
                "channel": 1
              }
            ]')
          else
            update_assignedchannels
          end
          @@i += 1
        end

        # Refreshes official channel live status
        def update_official_live
          was_official_live = @official_live
          @official_live = false
          @bot.assignedchannels.each do |channel|
            @official_live = true if is_online?(channel) && is_official?(channel)
          end
          update_primary_channel_topic(' <>') if was_official_live && !@official_live
        end

        # Formats channel announcement message
        def get_announce_message(channel)
          # Extract the info we need crom channel object
          name        = channel['friendlyalias']
          description = channel['twitch_yt_description']
          url         = channel['urltoplayer']
          upcoming    = is_upcoming?(channel)
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
          update_primary_channel_topic(output) if is_official?(channel)
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

        def refresh_announced_list
          clean_announced_list(@already_announced.find_all { |announced| is_upcoming?(announced) }, true)
          clean_announced_list(@already_announced.find_all { |announced| !is_upcoming?(announced) })
        end

        def clean_announced_list(channel_array, upcoming=false)
          channel_array.each do |existing_ch|
            @bot.debug "Checking to see if #{existing_ch['friendlyalias']} is still there"
            channel = @bot.assignedchannels.find { |assigned| existing_ch['streamid'] == assigned['streamid'] }
            @already_announced.delete(existing_ch)
            if channel.nil? || (upcoming && !is_upcoming?(channel)) || (!upcoming && !is_online?(channel))
              @bot.debug "Nope, removing from already announced"
            else
              @bot.debug "Yep, updating details"
              @already_announced << channel
            end
          end
        end
    end

  end
end
