# file: lib/cinch/plugins/kill.rb

require 'cinch'
require 'cinch/extensions/authentication'

module Cinch
  module Plugins
    class Kill
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      enable_authentication

      match ->(m) { /kill #{m.bot.nick}$/ }

      def execute(m)
        @bot.quit "I've been murdered by #{m.user.name}"
      end
    end
  end
end
