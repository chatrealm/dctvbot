# file: lib/services/dctv_channel_checker.rb

require 'active_support/time'

require_relative '../helpers/channel_helper'

module Services
    class DctvChannelChecker

        def initialize(dctv_api, cinch_bot, delay=5)
            @dctv_api = dctv_api
            @cinch_bot = cinch_bot
            @delay = delay

            @official_live = false
            @current_channels = @dctv_api.get_current_channels
        end

        def start
            while true
                sleep @delay
                run if @cinch_bot.channels.length > 0
            end
        end

        private

            attr_accessor :cinch_bot, :current_channels, :dctv_api, :delay, :official_live, :thread

            def run
                channels_to_announce = Array.new
                former_channels = @current_channels
                was_official_live = @official_live

                @official_live = false
                @current_channels = @dctv_api.get_current_channels

                @current_channels.each do |current_channel|
                    if ChannelHelper.is_live?(current_channel) && ChannelHelper.is_official?(current_channel)
                        @official_live = true
                    end

                    matched_former_channel = former_channels.find { |former_channel| current_channel['streamid'] == former_channel['streamid'] }

                    if !matched_former_channel.nil?
                        was_upcoming_now_live = ChannelHelper.is_upcoming?(matched_former_channel) && ChannelHelper.is_live?(current_channel)
                        next unless was_upcoming_now_live
                    end

                    channels_to_announce << current_channel
                end

                official_channel_to_announce = channels_to_announce.find { |channel_to_announce| ChannelHelper.is_official?(channel_to_announce) }

                if !official_channel_to_announce.nil?
                    message = format_irc_announce_message_for_channel(official_channel_to_announce)
                    @cinch_bot.handlers.dispatch(:update_topic, nil, @cinch_bot.channels.first, message)
                end

                return if @official_live

                if was_official_live && !@official_live
                    @cinch_bot.handlers.dispatch(:update_topic, nil, @cinch_bot.channels.first, ' <>')
                end

                channels_to_announce.each do |channel_to_announce|
                    message = format_irc_announce_message_for_channel(channel_to_announce)
                    @cinch_bot.handlers.dispatch(:make_announcement, nil, @cinch_bot.channels.first, message)
                end
            end

            def format_irc_announce_message_for_channel(dctv_channel)
                name        = dctv_channel['friendlyalias']
                description = dctv_channel['twitch_yt_description']
                url         = dctv_channel['urltoplayer']
                upcoming    = ChannelHelper.is_upcoming?(dctv_channel)

                status = @cinch_bot.Format(:white, :red, ' LIVE ')
                status = @cinch_bot.Format(:black, :yellow, ' UP NEXT ') if upcoming

                msg  = "#{status} #{name}"
                msg += " - #{description}" unless description.empty?
                msg += " - #{url}" unless url.empty?
                return msg
            end
    end
end
