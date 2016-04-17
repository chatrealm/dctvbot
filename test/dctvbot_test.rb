# file: test/dctvbot_test.rb

require 'minitest/autorun'

class DctvbotTest < Minitest::Test

    def test_set_option_sets_property
        dctvbot = Dctvbot.new
        dctvbot.set_option(:nick, 'dctvbot')
        assert dctvbot.nick == 'dctvbot'
    end

end
