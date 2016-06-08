# file lib/services/google_calendar.rb

require 'active_support/time'
require 'httparty'

module Services
  class GoogleCalendar
    include HTTParty

    base_uri 'https://www.googleapis.com/calendar/v3/calendars'

    def initialize(api_key)
      @api_key = api_key
    end

    def get_calendar(calendar_id, options = {})
      get_calendar_entries(calendar_id, options)
    end

    private

    attr_accessor :api_key

    def get_calendar_entries(calendar_id, options = {})
      defaults = {
        query: {
          key: @api_key,
          singleEvents: true,
          orderBy: 'startTime',
          timeMin: DateTime.now,
          timeMax: DateTime.now + 48.hours
        }
      }
      options = defaults.merge(options)
      response = self.class.get("/#{calendar_id}/events", options)
      JSON.parse(response.body)['items']
    end
  end
end
