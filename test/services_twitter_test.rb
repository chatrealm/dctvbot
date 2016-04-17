# file: test/services_twitter_test.rb

require 'test_helper'
require 'yaml'
require 'service/twitter'

class ServicesTwitterTest < Minitest::Test

    # setup method
    def setup

        # load config file
        @config = YAML.load(File.open 'config.test.yml')

    end

    # test to make sure client property is correct type
    def test_client_is_twitter_client

        # create instance of twitter service
        twitter_service = Services::Twitter.new(
            @config['twitter']['consumer-key'],
            @config['twitter']['consumer-secret'],
            @config['twitter']['access-token'],
            @config['twitter']['access-token-secret']
        )

        # check client type
        assert_kind_of Twitter::REST::Client, twitter_service.client

    end

end
