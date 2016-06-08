# file: test/helpers/time_helper_test.rb

require 'helpers/time_helper'

class TimeHelperTest < Minitest::Test
  def test_time_until
    assert_equal('10 seconds ago', TimeHelper.time_until(Time.now - 10.seconds))
  end
end
