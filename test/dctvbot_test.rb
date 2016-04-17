# file: test/dctvbot_test.rb

require 'test_helper'
require 'dctvbot'

class DctvbotTest < Minitest::Test

    def test_initialize_loads_config_from_supplied_config_file
        dctvbot = Dctvbot.new('config.test.yml')
        assert_equal(dctvbot.config[:irc][:nick], 'testbot')
    end

end
