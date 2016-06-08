# file: lib/helpers/time_helper.rb

require 'time_sentence'

class TimeHelper
  def self.time_until(time, timezone = 'US/Eastern')
    diff_in_seconds = (time.in_time_zone(timezone) - Time.new).round
    diff_in_seconds.seconds.to_time_sentence
  end
end
