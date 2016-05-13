# file lib/services/google_calendar.rb

require 'httparty'

module Services
	class GoogleCalendar
		include HTTParty

		base_uri 'googleapis.com/calendar/v3/calendars'

		def initialize(api_key)
			@api_key = api_key
		end

		def get_calendar(calendar_id, options={})
			result = get_calendar_entries('a5jeb9t5etasrbl6dt5htkv4to@group.calendar.google.com')
			return result
		end

		private

			attr_accessor :api_key

			def self.get_calendar_entries(calendar_id, options={})
				options = {
					query: {
						key: @api_key,
		    			singleEvents: true,
		    			orderBy: 'startTime',
						timeMin: DateTime.now,
		    			timeMax: DateTime.now + 48.hours
					}
				}
				response = self.class.get("/#{calendar_id}/events", options)
				return JSON.parse(response.body)['items']
			end
	end
end
