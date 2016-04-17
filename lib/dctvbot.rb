# file: lib/dctvbot.rb

require 'yaml'

class Dctvbot

    # read-only properties
    attr_reader :config, :twitter

    # public methods
    def initialize(config_file)

        # load config from yaml
        @config = YAML.load(File.open config_file)

        # initialize twitter service
        @twitter = Services::Twitter.new(
            @config['twitter']['consumer-key'],
            @config['twitter']['consumer-secret'],
            @config['twitter']['access-token'],
            @config['twitter']['access-token-secret']
        )

    end

    # private methods
    private

    # set options/config
    # Connect to twitter, irc, and discord (+ slack?)
    # listen for commands, mentions, or other important conversation
    # respond to commands as nessecary
end
