# file: lib/cinch/plugins/dctv_calendar.rb

require 'cinch'
require 'cinch/extensions/authentication'

require_relative '../../helpers/time_helper'
require_relative '../../helpers/url_helper'

module Cinch
  module Plugins
    class DctvCalendar
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      DCTV_CALENDAR_ID = 'a5jeb9t5etasrbl6dt5htkv4to@group.calendar.google.com'.freeze

      match(/next\s?\-?(v?)/, method: :next_shows)
      match(/schedule\s?\-?(v?)/, method: :schedule)

      def initialize(*args)
        super
        @google_calendar = config[:google_calendar]
      end

      def next_shows(m, flag = nil)
        entry = nil
        calendar_entries = @google_calendar.get_calendar(DCTV_CALENDAR_ID)
        calendar_entries.each do |e|
          next if e['start']['dateTime'].nil?
          entry = e
          break
        end
        output = "Next scheduled show: #{CGI.unescape_html(entry['summary'])} (#{TimeHelper.time_until(entry['start']['dateTime'])})"
        flag == 'v' && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      def schedule(m, flag = nil)
        entries = @google_calendar.get_calendar(DCTV_CALENDAR_ID)
        output =  'Here are the scheduled shows for the next 48 hours:'
        entries.each do |entry|
          output += "\n#{CGI.unescape_html(entry['summary'])}"
          output += " - #{UrlHelper.time_is_link(entry['start']['dateTime'], true)}" if entry['start']['date'].nil?
        end
        flag == 'v' && authenticated?(m) ? m.reply(output) : m.user.notice(output)
      end

      private

      attr_accessor :google_calendar
    end
  end
end
