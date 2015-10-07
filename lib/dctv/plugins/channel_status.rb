require 'active_support'
require 'active_support/time'
require 'cgi'
require 'rexml/document'
require 'time_sentence'

module DCTV
  module Plugins
    class ChannelStatus
      include REXML
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      match(/now\s?\-?(v?)/, method: :now)
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

      match(/next\s?\-?(v?)/, method: :next)
      def next(m, flag=nil)
        entry = nil
        get_calendar_entries(3).each do |e|
          next if e['time'] == 0 || e['time'] < Time.new
          entry = e
          break
        end
        output = "Next scheduled show: #{CGI.unescape_html entry['title']} (#{time_until(entry['time'])})"
        flag == "v" && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      match(/schedule\s?\-?(v?)/, method: :schedule)
      def schedule(m, flag=nil)
        entries = get_calendar_entries
        output =  "Here are the scheduled shows for the next 48 hours:"
        entries.each do |entry|
          if entry["time"] == 0 || entry["time"] - 48.hours < Time.new
            output += "\n#{CGI.unescape_html entry["title"]}"
            output += " - #{time_is_link(entry["time"], true)}" unless entry["time"] == 0
          end
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

      def get_calendar_entries(num_entries=10)
        xml = get_calendar_xml(num_entries)
        parse_calendar_xml(xml)
      end

      def get_calendar_xml(num_entries=10)
        uri = URI.parse("http://www.google.com/calendar/feeds/a5jeb9t5etasrbl6dt5htkv4to%40group.calendar.google.com/public/basic")
        params = { orderby: "starttime", singleevents:"true", sortorder: "ascending", futureevents: "true", ctz: "US/Eastern", 'max-results' => "#{num_entries}" }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        Document.new(response.body)
      end

      def parse_calendar_xml(xml)
        response = Array.new
        xml.elements.each('feed/entry') do |entry|
          calendar_item = Hash.new
          entry.elements.each('title') { |title| calendar_item['title'] = title.text }
          entry.elements.each('content') do |content|
            content.text =~ /when:\s(.+)\sto/i
            calendar_item['time'] = Time.parse("#{$1} EDT")
            calendar_item['time'] = 0 if $1 == nil
          end
          response << calendar_item
        end
        return response
      end

    end
  end
end
