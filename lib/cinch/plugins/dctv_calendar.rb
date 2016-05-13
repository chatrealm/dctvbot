# file: lib/cinch/plugins/dctv_calendar.rb

require 'cinch'

require_relative '/lib/services/google_calendar'

module Cinch
	module Plugins
		class DctvCalendar
			include Cinch::Plugin

			match(/next\s?\-?(v?)/, method: :next)

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
		end
	end
end
