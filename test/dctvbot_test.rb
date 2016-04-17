# file: test/dctvbot_test.rb

require 'test_helper'
require 'dctvbot'

class DctvbotTest < Minitest::Test

    # setup method
    def setup

        # instance variable for dctvbot
        @dctvbot = Dctvbot.new('config.test.yml')

    end

    # make sure initialize loads config correctly
    def test_initialize_loads_config_from_supplied_yaml_file

        # get sample from config
        result = @dctvbot.config['irc']['nick']

        # check if it's what was expected
        assert_equal(result, 'testbot', "Expected 'testbot', got '#{result}'")

    end

end
