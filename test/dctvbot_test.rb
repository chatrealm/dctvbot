# file: test/dctvbot_test.rb

require 'test_helper'
require 'dctvbot'

class DctvbotTest < Minitest::Test

    def test_initialize_loads_config_from_supplied_yaml_file
        dctvbot = Dctvbot.new('config.test.yml')
        result = dctvbot.config['irc']['nick']
        assert_equal(result, 'testbot', "Expected 'testbot', got '#{result}'")
    end

end
