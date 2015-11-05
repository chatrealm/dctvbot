module Cinch
  module Plugins

    class Kill
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      set :help_msg, "!kill <bot_nick> - Tells bot to quit completely, you must specify correct <bot_nick>."

      enable_authentication

      match lambda { |m| /kill #{m.bot.nick}$/ }

      def execute(m)
        @bot.debug "Executing quit command requested by #{m.user.name}"
        @bot.quit "I've been murdered by #{m.user.name}"
      end
    end

  end
end
