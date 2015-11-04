require 'active_support'
require 'active_support/time'
require 'cgi'
require 'json'
require 'time_sentence'

module DCTV
  module Plugins
    class ChannelStatus
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      set :plugin_name, "dctvstatus"
      set :help_msg, "!now [-v] - Display channels that are currently live via user notice.\n!next [-v] - Display next scheduled show and estimated time until it starts.\n!schedule [-v] - Display scheduled shows for the next 48 hours via user notice."

      match /now\s?\-?(v?)/, method: :now
      def now(m, flag=nil)
        output = ""
        @bot.assignedchannels.sort_by!{ |c| c['channel'] }.each do |channel|
          unless channel['yt_upcoming']
            output += "Ch. #{channel['channel']}"
            output += " - #{channel['friendlyalias']}"
            output += " - #{channel['twitch_yt_description']}" unless channel['twitch_yt_description'].blank?
            output += " - #{channel['urltoplayer']}\n"
          end
        end
        output = "Nothing is currently live" if @bot.assignedchannels.count == 0
        flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      match /next\s?\-?(v?)/, method: :next
      def next(m, flag=nil)
        entry = nil
        get_calendar_entries.each do |e|
          next if e['start']['dateTime'] === nil
          entry = e
          break
        end
        output = "Next scheduled show: #{CGI.unescape_html(entry['summary'])} (#{time_until(entry['start']['dateTime'])})"
        flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      match /schedule\s?\-?(v?)/, method: :schedule
      def schedule(m, flag=nil)
        entries = get_calendar_entries
        output =  "Here are the scheduled shows for the next 48 hours:"
        entries.each do |entry|
          output += "\n#{CGI.unescape_html(entry['summary'])}"
          output += " - #{time_is_link(entry['start']['dateTime'], true)}" if entry['start']['date'] === nil
        end
        flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      private

      def time_is_link(time, include_day=false, timezone='US/Eastern')
        time = time.in_time_zone(timezone)
        return "http://time.is/#{time.strftime("%H%M_%Z")}" unless include_day
        return "http://time.is/#{time.strftime("%H%M_%d_%b_%Y_%Z")}"
      end

      def time_until(time, timezone='US/Eastern')
        differenceInSeconds = (time.in_time_zone(timezone) - Time.new).round
        return differenceInSeconds.seconds.to_time_sentence
      end

      def get_calendar_entries
        uri = URI.parse('https://www.googleapis.com/calendar/v3/calendars/a5jeb9t5etasrbl6dt5htkv4to%40group.calendar.google.com/events')
        params = {
          key: config[:google_api_key],
          singleEvents: true,
          orderBy: 'startTime',
          timeMin: DateTime.now,
          timeMax: DateTime.now + 48.hours
        }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)['items']
      end

    end
  end
end
