# file: lib/dctvbot.rb

class Dctvbot
    # public properties
    attr_accessor :nick

    # public methods

    def initialize
        @nick = '';
    end

    def set_option(property, value)
        # raise an error if the property doesn't exist
        raise "Property does not exist." unless instance_variable_defined? "@#{property}"

        # set supplied property to supplied value
        instance_variable_set("@#{property}", value)
    end

    # set options/config
    # Connect to twitter, irc, and discord (+ slack?)
    # listen for commands, mentions, or other important conversation
    # respond to commands as nessecary
end
