# file: test/twitter_service_test.rb

require 'test_helper'
require 'yaml'
require 'twitter_service'

class TwitterServiceTest < Minitest::Test

    # setup method
    def setup

        # load config file
        @config = YAML.load(File.open 'config.test.yml')

    end

    # test to make sure client property is correct type
    def test_client_is_twitter_client

        twitter_service = TwitterService.new(
            @config['twitter']['consumer-key'],
            @config['twitter']['consumer-secret'],
            @config['twitter']['access-token'],
            @config['twitter']['access-token-secret']
        )

        assert_kind_of Twitter::REST::Client, twitter_service.client

    end

end
