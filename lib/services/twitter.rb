# file lib/services/twitter.rb

require 'twitter'
require 'services/service'

class Services::Twitter < Services::Service

    # read-only properties
    attr_reader :client

    # public methods
    def initialize(key, secret, token, token_secret)

        # create twitter client
        @client = ::Twitter::REST::Client.new do |c|
            c.consumer_key          = key
            c.consumer_secret       = secret
            c.access_token          = token
            c.access_token_secret   = token_secret
        end

    end

    # private methods
    private

end
