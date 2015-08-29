# encoding: utf-8

require 'rexml/document'

module Plugins
  module DCTV
    class Status

      include REXML
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      match /now\s?\-{0,2}(v?)(?:erbose)?/, method: :now
      def now(m, flag=nil)
        return unless (@bot.dctv_commands_enabled || authenticated?(m))
        response = Net::HTTP.get_response(URI.parse('http://diamondclub.tv/api/channelsv2.php'))
        apiResult = JSON.parse(response.body)['assignedchannels']
        onCount = 0
        output = ""
        apiResult.each do |result|
          unless result['yt_upcoming']
            output += "#{result['friendlyalias']} is live on Channel #{result['channel']} - #{result['urltoplayer']}\n"
            onCount += 1
          end
        end
        if onCount == 0
          output = "Nothing is currently live"
        end

        if flag == "v" && authenticated?(m)
          m.reply output
        else
          m.user.notice output
        end
      end

      match /next/, method: :next
      def next(m)
        return unless (@bot.dctv_commands_enabled || authenticated?(m))
        entries = getCalendarEntries(2)
        if entries[0]["time"] < Time.new
          entry = entries[1]
        else
          entry = entries[0]
        end
        title = CGI.unescape_html entry["title"]
        m.user.notice "Next scheduled show: #{title} (#{timeUntil(entry["time"])})"
      end

      match /schedule\s?\-{0,2}(v?)(?:erbose)?/, method: :schedule
      def schedule(m, flag=nil)
        return unless (@bot.dctv_commands_enabled || authenticated?(m))
        entries = getCalendarEntries
        output =  "Here are the scheduled shows for the next 48 hours:"
        entries.each do |entry|
          if entry["time"] - 48.hours < Time.new
            title = CGI.unescape_html entry["title"]
            output += "\n#{title} - #{timeIsLink(entry["time"], true)}"
          end
        end
        if flag == "v" && authenticated?(m)
          m.reply output
        else
          m.user.notice output
        end
      end

      private

        def timeIsLink(time, includeDay=false, timezone='US/Eastern')
          time = time.in_time_zone(timezone)
          return "http://time.is/#{time.strftime("%H%M_%Z")}" unless includeDay
          return "http://time.is/#{time.strftime("%H%M_%d_%b_%Y_%Z")}"
        end

        def timeUntil(time, timezone='US/Eastern')
          time = time.in_time_zone(timezone)
          differenceInSeconds = (time - Time.new).round
          return differenceInSeconds.seconds.to_time_sentence
        end

        def getCalendarEntries(numEntries=10)
          uri = URI.parse("http://www.google.com/calendar/feeds/a5jeb9t5etasrbl6dt5htkv4to%40group.calendar.google.com/public/basic")
          params = {
            orderby: "starttime",
            singleevents:"true",
            sortorder: "ascending",
            futureevents: "true",
            ctz: "US/Eastern",
            'max-results' => "#{numEntries}"
          }
          uri.query = URI.encode_www_form(params)
          response = Net::HTTP.get_response(uri)
          xml = Document.new(response.body)
          response = Array.new
          xml.elements.each("feed/entry") do |entry|
            calItem = Hash.new
            entry.elements.each("title") do |title|
              calItem["title"] = title.text
            end
            entry.elements.each("content") do |content|
              content.text =~ /when:\s(.+)\sto/i
              calItem["time"] = Time.parse("#{$1} EDT")
            end
            response << calItem
          end
          return response
        end

    end
  end
end
