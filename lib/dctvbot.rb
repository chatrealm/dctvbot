# file: lib/dctvbot.rb

require 'yaml'

class Dctvbot

    # read-only properties
    attr_reader :config

    # public methods
    def initialize(config_file)

        # load config from yaml
        @config = YAML.load(File.open config_file)
        
    end

    # private methods
    private

    # set options/config
    # Connect to twitter, irc, and discord (+ slack?)
    # listen for commands, mentions, or other important conversation
    # respond to commands as nessecary
end
