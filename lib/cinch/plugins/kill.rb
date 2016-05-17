# file: lib/cinch/plugins/kill.rb

require 'cinch'
require 'cinch/extensions/authentication'

module Cinch
    module Plugins

        class Kill
            include Cinch::Plugin
            include Cinch::Extensions::Authentication

            enable_authentication

            match lambda { |m| /kill #{m.bot.nick}$/ }

            def execute(m)
                # @bot.debug "Executing quit command requested by #{m.user.name}"
                @bot.quit "I've been murdered by #{m.user.name}"
            end
        end

    end
end
