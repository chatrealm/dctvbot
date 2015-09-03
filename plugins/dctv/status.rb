# encoding: utf-8

require 'rexml/document'

module Plugins
  module DCTV
    class Status

      include REXML
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      match /now\s?\-?(v?)/, method: :now
      def now(m, flag=nil)
        return unless (@bot.dctv_commands_enabled || authenticated?(m))
        response = Net::HTTP.get_response(URI.parse('http://diamondclub.tv/api/channelsv2.php'))
        current_channels = JSON.parse(response.body)['assignedchannels']
        output = ""
        current_channels.each { |channel| output += "#{channel['friendlyalias']} is live on Channel #{channel['channel']} - #{channel['urltoplayer']}\n" unless channel['yt_upcoming'] }
        output = "Nothing is currently live" if current_channels.count == 0
        flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      match /next\s?\-?(v?)/, method: :next
      def next(m, flag=nil)
        return unless (@bot.dctv_commands_enabled || authenticated?(m))
        entries = get_calendar_entries 2
        entries[0]['time'] < Time.new ? entry = entries[1] : entry = entries[0]
        output = "Next scheduled show: #{CGI.unescape_html entry['title']} (#{time_until(entry['time'])})"
        flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      match /schedule\s?\-?(v?)/, method: :schedule
      def schedule(m, flag=nil)
        return unless (@bot.dctv_commands_enabled || authenticated?(m))
        entries = get_calendar_entries
        output =  "Here are the scheduled shows for the next 48 hours:"
        entries.each { |entry| output += "\n#{CGI.unescape_html entry["title"]} - #{timeIsLink(entry["time"], true)}" if entry["time"] - 48.hours < Time.new }
        flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      private

        def timeIsLink(time, include_day=false, timezone='US/Eastern')
          time = time.in_time_zone(timezone)
          return "http://time.is/#{time.strftime("%H%M_%Z")}" unless include_day
          return "http://time.is/#{time.strftime("%H%M_%d_%b_%Y_%Z")}"
        end

        def time_until(time, timezone='US/Eastern')
          differenceInSeconds = (time.in_time_zone(timezone) - Time.new).round
          return differenceInSeconds.seconds.to_time_sentence
        end

        def get_calendar_entries(num_entries=10)
          uri = URI.parse("http://www.google.com/calendar/feeds/a5jeb9t5etasrbl6dt5htkv4to%40group.calendar.google.com/public/basic")
          params = {
            orderby: "starttime",
            singleevents:"true",
            sortorder: "ascending",
            futureevents: "true",
            ctz: "US/Eastern",
            'max-results' => "#{num_entries}"
          }
          uri.query = URI.encode_www_form(params)
          response = Net::HTTP.get_response(uri)
          xml = Document.new(response.body)
          response = Array.new
          xml.elements.each('feed/entry') do |entry|
            calendar_item = Hash.new
            entry.elements.each('title') { |title| calendar_item['title'] = title.text }
            entry.elements.each('content') do |content|
              content.text =~ /when:\s(.+)\sto/i
              if $1 == nil
                calendar_item['time'] = "All Day (or Unknown)"
              else
                calendar_item['time'] = Time.parse("#{$1} EDT")
              end
            end
            response << calendar_item
          end
          return response
        end

    end
  end
end
