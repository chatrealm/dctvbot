# file: test/twitter_service_test.rb

require 'yaml'
require 'test_helper'

class TwitterServiceTest < Minitest::Test

    # setup method
    def setup

        # load config file
        @config = YAML.load(File.open 'config.test.yml')

    end
end
