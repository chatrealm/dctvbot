# file: test/dctvbot_test.rb

require 'test_helper'
require 'dctvbot'

class DctvbotTest < Minitest::Test

    def setup
        @dctvbot = Dctvbot.new('config.test.yml')
    end

    def test_initialize_loads_config_from_supplied_yaml_file
        dctvbot = Dctvbot.new('config.test.yml')
        result = dctvbot.config['irc']['nick']
        assert_equal(result, 'testbot', "Expected 'testbot', got '#{result}'")
    end

    def test_twitter_service_is_twitter_service
        assert_is_kind_of TwitterService, @dctvbot.twitter_service
    end

end
