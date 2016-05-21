# file: lib/helpers/url_helper.rb

class UrlHelper

	def self.time_is_link(time, include_day=false, timezone='US/Eastern')
		time = time.in_time_zone(timezone)
		return "http://time.is/#{time.strftime("%H%M_%Z")}" unless include_day
		return "http://time.is/#{time.strftime("%H%M_%d_%b_%Y_%Z")}"
	end
	
end
