# file: lib/cinch/plugins/announcer.rb

require 'cinch'

module Cinch
  module Plugins
    class Announcer
      include Cinch::Plugin

      listen_to :make_announcement

      def listen(_m, channel, announcement)
        Channel(channel).send(announcement)
      end
    end
  end
end
