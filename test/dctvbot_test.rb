# file: test/dctvbot_test.rb

require 'test_helper'

require 'dctvbot'

class DctvbotTest < Minitest::Test

    def test_set_option_sets_property
        dctvbot = Dctvbot.new
        dctvbot.set_option(:nick, 'dctvbot')
        assert_equal dctvbot.nick, 'dctvbot', "Expected 'dctvbot', got #{dctvbot.nick}"
    end

end
