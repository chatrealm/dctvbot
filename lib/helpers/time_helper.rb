#file: lib/helpers/time_helper.rb

require 'time_sentence'

class TimeHelper

	def self.time_until(time, timezone='US/Eastern')
		differenceInSeconds = (time.in_time_zone(timezone) - Time.new).round
		return differenceInSeconds.seconds.to_time_sentence
	end

end
